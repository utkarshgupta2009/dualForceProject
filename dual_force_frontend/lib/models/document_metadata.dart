
class DocumentMetadata {
  final String id;
  final String filename;
  final String contentType;
  final int sizeBytes;
  final int totalChunks;
  final DateTime createdAt;

  DocumentMetadata({
    required this.id,
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
    required this.totalChunks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'totalChunks': totalChunks,
      'createdAt': createdAt,
    };
  }

  factory DocumentMetadata.fromMap(Map<String, dynamic> map) {
    return DocumentMetadata(
      id: map['id'],
      filename: map['filename'],
      contentType: map['contentType'],
      sizeBytes: map['sizeBytes'],
      totalChunks: map['totalChunks'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}