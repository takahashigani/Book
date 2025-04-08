import 'package:frontend/domain/entities/book.dart';
import '../repository/book_repository.dart';

class GetAllBooks
{
  final BookRepository repository;
  GetAllBooks(this.repository);

  Future<List<Book>> call() async
  {
    return await repository.getAllBooks();
  }
}