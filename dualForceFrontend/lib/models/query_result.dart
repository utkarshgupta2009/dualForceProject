class QueryResult {
  final String content;
  final String source;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  QueryResult({
    required this.content,
    required this.source,
    required this.relevanceScore,
    required this.metadata,
  });
}