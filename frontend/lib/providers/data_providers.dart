// GoogleBookDataSourceのProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/datasources/google_bools_data_source.dart';
import 'package:http/http.dart' as http;

// GoogleBooksDataSourceのProvider
final googleBookDataSourceProvider = Provider<GoogleBooksDataSource>((ref){
  final client = ref.watch(httpClientProvider);
  return GoogleBooksDataSourceImpl(client: client);
});

// http通信のためのProvider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());