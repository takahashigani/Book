import '../entities/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooksByStatus(ReadingStatus status);

  Future<void> addBook(Book book);

  Future<void> updateBookStatus(int id, ReadingStatus status);

  Future<List<Book>> getAllBooks();

  Future<void> deleteBook(int id);
}