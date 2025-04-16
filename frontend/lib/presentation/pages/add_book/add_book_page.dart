import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/serched_book_model.dart';
import 'package:frontend/domain/usecases/add_book.dart';
import 'package:frontend/providers/presentation_providers.dart';

import '../../../domain/entities/book.dart';
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
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  ref
                      .read(searchKeywordProvider.notifier)
                      .state = text;
                },
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
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

        error: (error, stack) =>
            Center(
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
                final imageUrl = volumeInfo.imageLinks?.thumbnail ??
                    volumeInfo.imageLinks?.smallThumbnail;

                return ListTile(
                    leading: imageUrl != null
                        ? Image.network(imageUrl, width: 40, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                      const Icon(Icons.broken_image, size: 40,),)
                        : const Icon(Icons.book, size: 40,),
                    title: Text(volumeInfo.title),
                    subtitle: Text(
                        volumeInfo.authors?.join(', ') ?? '著者不明'),
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

  void _showAddBookDialog(BuildContext context, WidgetRef ref,
      SearchedBookModel book) {
    final volumeInfo = book.volumeInfo;
    ReadingStatus selectedStatus = ReadingStatus.wantToRead;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
              builder: (stfContext, setState) {
                return AlertDialog(
                  title: Text(volumeInfo.title, maxLines: 2,
                      overflow: TextOverflow.ellipsis),

                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(volumeInfo.authors?.join(', ') ?? '著者不明'),
                      const SizedBox(height: 16),
                      const Text('ステータス選択'),
                      ...ReadingStatus.values.map((status) =>
                          RadioListTile<ReadingStatus>(
                            title: Text(_statusToString(status)), // 日本語表示
                            value: status, // このラジオボタンの値
                            groupValue: selectedStatus, // 現在選択されている値
                            onChanged: (value) {
                              if (value != null) {
                                // ラジオボタンが変更されたら選択中ステータスを更新
                                setState(() { // StatefulBuilder の setState を呼ぶ
                                  selectedStatus = value;
                                });
                              }
                            },
                          )),
                    ],
                  ),
                  // ダイアログの下部ボタン
                  actions: [
                    TextButton( // キャンセルボタン
                      onPressed: () => Navigator.pop(dialogContext),
                      // ダイアログを閉じる
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton( // 登録ボタン
                      onPressed: () async { // 非同期処理にする (登録処理に時間がかかるかも)
                        // ★ 登録処理を実行 ★
                        try {
                          // 1. 登録用データ(Bookエンティティ)を作成
                          final newBook = Book(
                            // idはバックエンドで決まるので仮の値か、含めない
                            id: 0,
                            // 仮
                            title: volumeInfo.title,
                            author: volumeInfo.authors?.join(', ') ?? '',
                            publishedDate: volumeInfo.publishedDate != null
                                ? DateTime.tryParse(volumeInfo.publishedDate!)
                                : null,
                            summary: volumeInfo.description,
                            readingStatus: selectedStatus,
                            // ★選択されたステータスを使う★
                            pageCount: volumeInfo.pageCount,
                            coverImageUrl: volumeInfo.imageLinks?.thumbnail ??
                                volumeInfo.imageLinks?.smallThumbnail,
                            isbn: volumeInfo.industryIdentifiers
                                ?.firstWhere((id) => id.type.contains("ISBN"),
                                orElse: () =>
                                const IndustryIdentifierModel(
                                    type: '', identifier: ''))
                                .identifier,
                          );

                          // 2. 登録用UseCaseの窓口(addBookUseCaseProvider)から担当者を呼ぶ
                          //    (addBookUseCaseProvider が事前に定義されている前提)
                          //final addBook = ref.read(addBookUseCaseProvider);

                          // 3. 担当者に「この本を登録して！」とお願いする
                          //await addBook(newBook);

                          Navigator.pop(dialogContext); // ダイアログを閉じる

                          // 4. 成功メッセージを表示 (SnackBar)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                '『${volumeInfo.title}』を登録しました')),
                          );
                        } catch (e) { // もし登録処理でエラーが起きたら
                          print('登録エラー: $e');
                          Navigator.pop(dialogContext); // ダイアログを閉じる
                          // 5. エラーメッセージを表示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('登録に失敗しました: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('登録する'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  String _statusToString(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.reading:
        return '読書中';
      case ReadingStatus.completed:
        return '読了';
      case ReadingStatus.wantToRead:
        return '読みたい';
      default:
        return '不明';
    }
  }
}