import 'package:dual_force/services/book_api_service.dart';

import '../models/book_model.dart';

class BookRepository {
  final BookApiService _apiService = BookApiService();
  
  Future<List<Book>> searchBooks(String query) async {
    return await _apiService.searchBooks(query);
  }
}
