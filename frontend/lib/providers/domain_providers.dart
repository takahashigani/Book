// SearchBooks Usecaseの窓口(Provider)を作成
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecases/add_book.dart';
import 'package:frontend/domain/usecases/delete_book.dart';
import 'package:frontend/domain/usecases/get_books_by_status.dart';
import 'package:frontend/domain/usecases/search_books.dart';
import 'package:frontend/domain/usecases/update_book_status.dart';
import 'package:frontend/providers/data_providers.dart';

// SearchBooks Usecaseの窓口(Provider)を作成
final searchBooksUseCaseProvider = Provider<SearchBooks>((ref) {
  return SearchBooks(ref);
});

// GetBooksByStatus Usecaseの窓口(Provider)を作成
final getBooksByStatusUseCaseProvider = Provider<GetBooksByStatus>((ref){
  final repository = ref.watch(bookRepositoryProvider);
  return GetBooksByStatus(repository);
});

// UpdateBookStatus Usecaseの窓口(Provider)を作成
final updateBookStatusProvider = Provider<UpdateBookStatus>((ref){
  final repository = ref.watch(bookRepositoryProvider);
  return UpdateBookStatus(repository);
});

// 登録用UseCaseの窓口(addBookUseCaseProvider)
final addBookUseCaseProvider = Provider<AddBook>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return AddBook(repository);
});

// DeleteBook Usecaseの窓口(Provider)を作成
final deleteBookUseCaseProvider = Provider<DeleteBook>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return DeleteBook(repository);
});