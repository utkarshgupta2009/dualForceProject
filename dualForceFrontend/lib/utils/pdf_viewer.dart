import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PDFViewerScreen({
    required this.pdfUrl,
    required this.fileName,
    Key? key,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  File? pdfFile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        // Get temporary directory
        final dir = await getTemporaryDirectory();
        
        // Create PDF file in temporary directory
        pdfFile = File('${dir.path}/${widget.fileName}');
        
        // Write PDF bytes to file
        await pdfFile!.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load PDF: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading PDF: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : PDFView(
              filePath: pdfFile?.path,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = 'Error on page $page: $error';
                });
              },
            ),
    );
  }

  @override
  void dispose() {
    // Clean up the temporary file when done
    // ignore: invalid_return_type_for_catch_error
    pdfFile?.delete().catchError((e) => log('Error deleting temp file: $e'));
    super.dispose();
  }
}