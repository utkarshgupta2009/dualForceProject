import 'package:dual_force/models/book_model.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover and title
              Center(
                child: Column(
                  children: [
                    book.thumbnail.isNotEmpty
                      ? Image.network(
                          book.thumbnail,
                          height: 200,
                          errorBuilder: (_, __, ___) => 
                            Icon(Icons.book, size: 200),
                        )
                      : Icon(Icons.book, size: 200),
                    SizedBox(height: 16),
                    Text(
                      book.title,
                      style: AppTextStyle.titleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // Authors
              if (book.authors.isNotEmpty) ...[
                Text(
                  'Authors:',
                  style: AppTextStyle.subtitleTextStyleBlack,
                ),
                Text(book.authors.join(', ')),
                SizedBox(height: 8),
              ],
              
              // Publisher info
              if (book.publisher.isNotEmpty) ...[
                Text(
                  'Publisher:',
                  style: AppTextStyle.subtitleTextStyleBlack,
                ),
                Text('${book.publisher} ${book.publishedDate}'),
                SizedBox(height: 8),
              ],
              
              // Page count
              if (book.pageCount > 0) ...[
                Text(
                  'Pages:',
                  style: AppTextStyle.subtitleTextStyleBlack,
                ),
                Text('${book.pageCount}'),
                SizedBox(height: 8),
              ],
              
              // Description
              if (book.description.isNotEmpty) ...[
                Text(
                  'Description:',
                  style: AppTextStyle.subtitleTextStyleBlack,
                ),
                SizedBox(height: 4),
                Text(book.description),
                SizedBox(height: 16),
              ],
              
              // Preview link
              if (book.previewLink.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    // You would typically launch a URL here
                    // using url_launcher package
                    launchUrl(Uri.parse(book.previewLink));
                  },
                  child: Text('Preview Book'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}