import '../entities/book.dart';
import '../repository/book_repository.dart';

class UpdateBookStatus
{
  final BookRepository repository;
  UpdateBookStatus(this.repository);

  Future<void> call(int id, ReadingStatus status) async
  {
    await repository.updateBookStatus(id, status);
  }
}