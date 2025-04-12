import 'dart:convert';

import 'package:frontend/data/models/serched_book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class GoogleBooksDataSource
{
  Future<List<SearchedBookModel>> searchBooks(String query);
}

class GoogleBooksDataSourceImpl implements GoogleBooksDataSource{
  final http.Client client;
  final String apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
  final String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  GoogleBooksDataSourceImpl({required this.client});

  @override
  Future<List<SearchedBookModel>> searchBooks(String query) async{
    if(apiKey.isEmpty) throw Exception('API key is not set');

    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$baseUrl?q=$encodedQuery&maxResults=20&key=$apiKey');

    try{
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if(data.containsKey('items') && data['items'] is List) {
          final List<dynamic> items = data['items'];
          return items.map((item) => SearchedBookModel.fromJson(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Failed to connect to Google Books API: $e');
    }
  }
}

