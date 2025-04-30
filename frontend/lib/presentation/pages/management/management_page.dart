import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/entities/book.dart';
import 'package:frontend/presentation/notifiers/management/management_state.dart';
import 'package:frontend/providers/presentation_providers.dart';

class ManagementPage extends ConsumerWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(managementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('本管理')),
      body: Column(
        children: [
          _buildStatusSelector(ref, state.selectedStatus),
          const Divider(height: 1),
          Expanded(child: _buildBookList(ref, state)),
        ],
      ),
    );
  }

  // ---Widgetを構築するヘルパーメソッド---
  // ステータス選択ボタン
  Widget _buildStatusSelector(
      WidgetRef ref, ReadingStatus currentSelectedStatus) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: SegmentedButton<ReadingStatus>(
          segments: const <ButtonSegment<ReadingStatus>>[
            ButtonSegment(
                value: ReadingStatus.completed,
                label: Text('読了'),
                icon: Icon(Icons.check_circle_outline)),
            ButtonSegment(
                value: ReadingStatus.reading,
                label: Text('積読'),
                icon: Icon(Icons.book_outlined)),
            ButtonSegment(
                value: ReadingStatus.wantToRead,
                label: Text('読みたい'),
                icon: Icon(Icons.bookmark_border)),
          ],
          selected: {currentSelectedStatus},
          onSelectionChanged: (Set<ReadingStatus> newSelection) {
            ref
                .read(managementProvider.notifier)
                .fetchBooks(newSelection.first);
          },
          showSelectedIcon: false,
        ));
  }

  // 本の表示リスト
  Widget _buildBookList(WidgetRef ref, ManagementState state) {
    switch (state.status) {
      // 状況：ローディング中
      case ManagementStatus.loading:
        return const Center(child: CircularProgressIndicator());

      // 状況：本の取得に失敗
      case ManagementStatus.failure:
        return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('エラー： ${state.errorMessage}' ?? '不明なエラー'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .read(managementProvider.notifier)
                .fetchBooks(state.selectedStatus), // 再試行ボタン
            child: const Text('再試行'),
          )
        ]));

      // 状況：初期状態
      case ManagementStatus.initial:
        return const Center(child: Text('読み込み中...')); // 初期状態

      // 状況：本の取得に成功
      case ManagementStatus.Success:
        if (state.books.isEmpty) {
          return const Center(child: Text('このステータスの本はありません'));
        }

        return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(managementProvider.notifier)
                  .fetchBooks(state.selectedStatus);
            },
            child: ListView.builder(
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  final book = state.books[index];
                  final imageUrl = book.coverImageUrl;

                  return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 80,
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  // 画像がある場合
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                        child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      strokeWidth: 2,
                                    ));
                                  },
                                )
                              : Container(
                                  // 画像がない場合
                                  color: Colors.grey[200],
                                  child: Center(
                                      child: Icon(Icons.book,
                                          color: Colors.grey[400]))),
                        ),
                        // タイトルと著者名
                        title: Text(book.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(book.author,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          _showStatusChangeDialog(context, ref, book);
                        },
                      ));
                }));
    }
  }

  // ステータス変更ダイアログを表示するメソッド
  void _showStatusChangeDialog(BuildContext context, WidgetRef ref, Book book) {
    ReadingStatus selectedStatus = book.readingStatus;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (stfContext, setState) {
              return AlertDialog(
                title: Text(book.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                contentPadding:
                    const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ステータスを変更:'),
                    // ラジオボタンで選択肢を表示
                    ...ReadingStatus.values
                        .map((status) => RadioListTile<ReadingStatus>(
                              title: Text(_statusToString(status)),
                              value: status,
                              groupValue: selectedStatus,
                              onChanged: (value) {
                                if (value != null) {
                                  if(value == book.readingStatus) {
                                    // 選択した本を削除する
                                    ref.read(managementProvider.notifier).deleteBook(book.id);

                                  } else {
                                    // ステータスを変更する
                                    setState(() => selectedStatus = value);
                                  }
                                }
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            )),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('キャンセル'),
                  ),
                  ElevatedButton(
                    onPressed: selectedStatus == book.readingStatus ? null : () async {
                      try {
                        await ref.read(managementProvider.notifier).changeStatus(book.id, selectedStatus);
                        Navigator.pop(dialogContext);
                      }
                      catch (e) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('エラー： ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('変更'),
                  )
                ]
              );
            },
          );
        });
  }
  // Enumを日本語表示にするヘルパー関数
  String _statusToString(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead: return '読みたい';
      case ReadingStatus.reading: return '読んでる(積読)';
      case ReadingStatus.completed: return '読んだ';
    }
  }
}
