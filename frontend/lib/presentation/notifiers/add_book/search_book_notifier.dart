// 検索の進行状況と結果を管理する係 (AsyncNotifier)
// <List<SearchedBookModel>> は成功した場合に本のリストを持つことを示すimport 'dart:async';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/serched_book_model.dart';

import '../../../providers/domain_providers.dart';

class SearchBookNotifier extends AsyncNotifier<List<SearchedBookModel>> {

  // 最初の状態を設定
  @override
  FutureOr<List<SearchedBookModel>> build() {
    // 初期状態では空のリストを返す
    return [];
  }

  // 検索を実行するメソッド
  Future<void> search(String query) async {
    if (query.isEmpty) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final usecase = ref.read(searchBooksUseCaseProvider);
      final results = await usecase(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

  final searchBookProvider =
  AsyncNotifierProvider<SearchBookNotifier, List<SearchedBookModel>>(() {
    return SearchBookNotifier();
  });