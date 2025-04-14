import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return const Center(
      child: Text('ここに検索結果が入ります'),
    );
  }
}