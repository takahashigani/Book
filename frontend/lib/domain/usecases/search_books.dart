
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/serched_book_model.dart';
import '../../providers/data_providers.dart';

class SearchBooks{
  final Ref _ref;
  SearchBooks(this._ref);

  Future<List<SearchedBookModel>> call(String query) async {
    final dataSource = _ref.read(googleBookDataSourceProvider);
    return await dataSource.searchBooks(query);
  }
}