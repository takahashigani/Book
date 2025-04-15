import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/serched_book_model.dart';
import 'package:frontend/domain/usecases/add_book.dart';
import 'package:frontend/providers/presentation_providers.dart';

import '../../notifiers/add_book/search_book_notifier.dart';

class AddBookPage extends ConsumerWidget {
  const AddBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本を検索・登録'),
      ),
      body: Column(
        children: [
          // 検索バーを表示
          _buildSearchBar(context, ref),

          // 検索結果を表示
          Expanded(
            child: _buildSearchResults(ref),
          ),
        ]
      )
    );
  }

  // 検索バーを表示するWidget
  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final keyword = ref.watch(searchKeywordProvider);

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'キーワードを入力...',
                border:OutlineInputBorder(),
              ),
              onChanged: (text) {
                ref.read(searchKeywordProvider.notifier).state = text;
              },
              onSubmitted: (text) {
                if(text.isNotEmpty) {
                  ref.read(searchBookProvider.notifier).search(text);
                }
              },
            ),
          ),
          const SizedBox(width: 8.0),

          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('検索'),
            onPressed: keyword.isNotEmpty
              ? () {
                  ref.read(searchBookProvider.notifier).search(keyword);
                  FocusScope.of(context).unfocus();
                }
              : null,
          ),
        ]
      ),
    );
  }

  // 検索結果を表示するWidget
  Widget _buildSearchResults(WidgetRef ref) {
    final searchState = ref.watch(searchBookProvider);
    return searchState.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラー: $error'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final keyword = ref.read(searchKeywordProvider);
                ref.read(searchBookProvider.notifier).search(keyword);
              },
              child: const Text('再試行'),
            )
          ]
        )
      ),

      data: (books) {
        if (books.isEmpty) {
          return const Center(child: Text('本が見つかりませんでした'));
        }
        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final volumeInfo = book.volumeInfo;
            final imageUrl = volumeInfo.imageLinks?.thumbnail ?? volumeInfo.imageLinks?.smallThumbnail;

            return ListTile(
              leading: imageUrl != null
                  ? Image.network(imageUrl, width: 40, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40,),)
                  : const Icon(Icons.book, size: 40,),
              title: Text(volumeInfo.title),
              subtitle: Text(volumeInfo.authors?.join(', ') ?? '著者不明'),
              onTap: () {
                print('本がタップされました: ${volumeInfo.title}');
                _showAddBookDialog(context, ref, book);
              }
            );
          }
        );
      }
    );
  }

  void _showAddBookDialog(BuildContext context, WidgetRef ref, SearchedBookModel book) {

  }
}