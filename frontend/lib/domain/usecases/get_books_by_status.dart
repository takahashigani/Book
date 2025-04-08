import '../entities/book.dart';
import '../repository/book_repository.dart';

class GetBooksByStatus
{
  final BookRepository repository;
  GetBooksByStatus(this.repository);

  Future<List<Book>> call(ReadingStatus status) async
  {
    return await repository.getBooksByStatus(status);
  }
}