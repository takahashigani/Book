import '../entities/book.dart';
import '../repository/book_repository.dart';

class AddBook
{
  final BookRepository repository;
  AddBook(this.repository);

  Future<void> call(Book book) async
  {
    return await repository.addBook(book);
  }
}