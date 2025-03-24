import 'package:dual_force/repository/book_repository.dart';
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

enum ViewState { initial, loading, loaded, error }

class BookViewModel with ChangeNotifier {
  final BookRepository _repository = BookRepository();
  
  List<Book> _books = [];
  String _errorMessage = '';
  ViewState _state = ViewState.initial;
  
  // Getters
  List<Book> get books => _books;
  String get errorMessage => _errorMessage;
  ViewState get state => _state;
  
  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      _books = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }
    
    try {
      _state = ViewState.loading;
      notifyListeners();
      
      final results = await _repository.searchBooks(query);
      
      _books = results;
      _state = ViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }
}