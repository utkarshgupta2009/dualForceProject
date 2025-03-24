// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BookApiService {
  final String baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  
  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) return [];
    
    final response = await http.get(
      Uri.parse('$baseUrl?q=$query&maxResults=40')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['items'] != null) {
        return List<Book>.from(
          data['items'].map((item) => Book.fromJson(item))
        );
      }
      return [];
    } else {
      throw Exception('Failed to load books');
    }
  }
}