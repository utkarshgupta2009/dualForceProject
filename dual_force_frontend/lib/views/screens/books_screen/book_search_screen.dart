import 'package:dual_force/models/book_model.dart';
import 'package:dual_force/viewmodels/book_viewmodel.dart';
import 'package:dual_force/views/screens/books_screen/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      Provider.of<BookViewModel>(context, listen: false)
        .searchBooks(_searchController.text);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Books Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
                hintText: 'Enter a book title, author, or keyword',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<BookViewModel>(
              builder: (context, viewModel, child) {
                switch (viewModel.state) {
                  case ViewState.initial:
                    return Center(
                      child: Text('Search for books to get started'),
                    );
                  
                  case ViewState.loading:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  
                  case ViewState.loaded:
                    if (viewModel.books.isEmpty) {
                      return Center(
                        child: Text('No books found'),
                      );
                    }
                    return BookListView(books: viewModel.books);
                  
                  case ViewState.error:
                    return Center(
                      child: Text(
                        'Error: ${viewModel.errorMessage}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookListView extends StatelessWidget {
  final List<Book> books;
  
  const BookListView({Key? key, required this.books}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: book.thumbnail.isNotEmpty
            ? Image.network(
                book.thumbnail,
                width: 50,
                errorBuilder: (_, __, ___) => Icon(Icons.book, size: 50),
              )
            : Icon(Icons.book, size: 50),
          title: Text(book.title),
          subtitle: Text(
            book.authors.isNotEmpty
              ? book.authors.join(', ')
              : 'Unknown Author'
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(book: book),
              ),
            );
          },
        );
      },
    );
  }
}