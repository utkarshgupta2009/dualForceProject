class DocumentChunk {
  final String id;
  final String content;
  final String source;
  final List<double> embedding;
  final Map<String, dynamic> metadata;

  DocumentChunk({
    required this.id,
    required this.content,
    required this.source,
    required this.embedding,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'content': content,
    'source': source,
    'embedding': embedding,
    'metadata': metadata,
  };

  factory DocumentChunk.fromJson(Map<String, dynamic> json) => DocumentChunk(
    id: json['_id'],
    content: json['content'],
    source: json['source'],
    embedding: List<double>.from(json['embedding']),
    metadata: json['metadata'],
  );
}