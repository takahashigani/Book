// SearchBooks Usecaseの窓口(Provider)を作成
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecases/search_books.dart';

final searchBooksProvider = Provider<SearchBooks>((ref) {
  return SearchBooks(ref);
});


