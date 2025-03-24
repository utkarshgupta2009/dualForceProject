class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnail;
  final int pageCount;
  final String previewLink;

  Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.publisher = '',
    this.publishedDate = '',
    this.description = '',
    this.thumbnail = '',
    this.pageCount = 0,
    this.previewLink = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var volumeInfo = json['volumeInfo'] ?? {};
    
    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'No Title',
      authors: volumeInfo['authors'] != null 
        ? List<String>.from(volumeInfo['authors']) 
        : [],
      publisher: volumeInfo['publisher'] ?? '',
      publishedDate: volumeInfo['publishedDate'] ?? '',
      description: volumeInfo['description'] ?? '',
      pageCount: volumeInfo['pageCount'] ?? 0,
      thumbnail: volumeInfo['imageLinks'] != null 
        ? volumeInfo['imageLinks']['thumbnail'] ?? '' 
        : '',
      previewLink: volumeInfo['previewLink'] ?? '',
    );
  }
}