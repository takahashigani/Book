import '../../domain/entities/book.dart';
import '../../domain/repository/book_repository.dart';
import '../datasources/book_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Book>> getBooksByStatus(ReadingStatus status) async {
    try{
      final List<Map<String, dynamic>>jsonList = await remoteDataSource.getBooksByStatus(status);
      return jsonList.map((json) => _mapJsonToBook(json)).toList();
    } catch (e) {
      print('Error fetching books by status: $e');
      return [];
    }
  }

  @override
  Future<List<Book>> getAllBooks() async {
    try{
      final List<Map<String, dynamic>>jsonList = await remoteDataSource.getAllBooks();
      return jsonList.map((json) => _mapJsonToBook(json)).toList();
    } catch (e) {
      print('Error fetching all books: $e');
      return [];
    }
  }

  @override
  Future<void> addBook(Book book) async {
    try{
      remoteDataSource.addBook(book);
    }catch (e) {
      print('Error adding book: $e');
    }
  }

  @override
  Future<void> updateBookStatus(int id, ReadingStatus status) async {
    try{
      remoteDataSource.updateBookStatus(id, status.name);
    }catch (e) {
      print('Error updating book status: $e');
    }
  }

  @override
  Future<void> deleteBook(int id) async{
    try{
      remoteDataSource.deleteBook(id);
    }catch (e) {
      print('Error deleting book: $e');
    }
  }

  // JSON(Map)をBookエンティティに変換するヘルパーメソッド (本来はModelクラスが担う)
  Book _mapJsonToBook(Map<String, dynamic> json) {
    // ここで型の変換やnullチェックを行う
    ReadingStatus status = ReadingStatus.values.firstWhere(
          (e) => e.toString() == 'ReadingStatus.${json['reading_status']}', // 文字列からEnumへ
      orElse: () => ReadingStatus.wantToRead, // 不明な値の場合のデフォルト
    );

    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      publishedDate: json['published_date'] != null ? DateTime.parse(json['published_date']) : null,
      summary: json['summary'] as String?,
      readingStatus: status, // 変換したEnumを使う
      pageCount: json['page_count'] as int?,
      coverImageUrl: json['cover_image_url'] as String?,
      isbn: json['isbn'] as String?,
    );
  }
}