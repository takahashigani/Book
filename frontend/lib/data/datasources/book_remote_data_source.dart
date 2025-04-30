import 'dart:convert';

import 'package:frontend/domain/entities/book.dart';
import 'package:http/http.dart' as http;

abstract class BookRemoteDataSource
{
  Future<List<Map<String, dynamic>>> getBooksByStatus(ReadingStatus status);
  Future<void> addBook(Book book);
  Future<void> updateBookStatus(int id, String status);
  Future<List<Map<String, dynamic>>> getAllBooks();
  Future<void> deleteBook(int id);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource
{
  final http.Client client = http.Client();
  final String baseUrl = 'http://10.0.2.2:8000'; // Replace with your backend URL

  @override
  Future<List<Map<String, dynamic>>> getBooksByStatus(ReadingStatus status) async
  {
    String statusString = status.name;
    if(status == ReadingStatus.wantToRead) statusString = 'want_to_read';

    final response = await client.get(
      Uri.parse('$baseUrl/books/?reading_status=$statusString'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200){
      // これを入れないと日本語が文字化けする
      List<int> bodyBytes = response.bodyBytes;
      String decodedBody = utf8.decode(bodyBytes);
      List<dynamic> jsonResponse = json.decode(decodedBody);
      return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Future<void> addBook(Book book) async
  {
    final response = await client.post(
      Uri.parse('$baseUrl/books/'),
      headers: {
        'Content-Type': 'application/json',
      },
      // bookのIDを除いたデータを送信
      body: json.encode(
        {
          'title': book.title,
          'author': book.author,
          'published_date': book.publishedDate?.toIso8601String(),
          'summary': book.summary,
          'reading_status': book.readingStatus.name,
          'page_count': book.pageCount,
          'cover_image_url': book.coverImageUrl,
          'isbn': book.isbn,
        },
      ),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  @override
  Future<void> updateBookStatus(int id, String status) async
  {
    final response = await client.patch(
      Uri.parse('$baseUrl/books/$id/status/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'reading_status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update book status');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBooks() async
  {
    final response = await client.get(
      Uri.parse('$baseUrl/books/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200){
     List<dynamic> jsonResponse = json.decode(response.body);
     return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Future<void> deleteBook(int id) async
  {
    final response = await client.delete(
      Uri.parse('$baseUrl/books/$id/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // 【Note】Might not be 204
    if (response.statusCode != 204) {
      throw Exception('Failed to delete book');
    }
  }
}

