abstract class BookRemoteDataSource
{
  Future<List<Map<String, dynamic>>> getBooksByStatus(String status);
  Future<void> addBook(Map<String, dynamic> book);
  Future<void> updateBookStatus(int id, String status);
  Future<List<Map<String, dynamic>>> getAllBooks();
  Future<void> deleteBook(int id);
}