enum ReadingStatus {
  wantToRead,
  reading,
  completed,
}

class Book {

  final int id;
  final String title;
  final String author;
  final DateTime? publishedDate;
  final String? summary;
  final ReadingStatus readingStatus;
  final int? pageCount;
  final String? coverImageUrl;
  final String? isbn;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.publishedDate,
    this.summary,
    required this.readingStatus,
    this.pageCount,
    this.coverImageUrl,
    this.isbn,
});
}