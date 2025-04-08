import 'package:frontend/domain/repository/book_repository.dart';

class DeleteBook
{
  final BookRepository bookRepository;
  DeleteBook(this.bookRepository);

  Future<void> call(int id) async
  {
    await bookRepository.deleteBook(id);
  }
}