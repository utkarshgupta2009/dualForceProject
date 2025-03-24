import 'package:dual_force/models/document_metadata.dart';

class ExpertSystem {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DocumentMetadata documentMetadata;

  ExpertSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.documentMetadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'documentMetadata': documentMetadata.toMap(),
    };
  }

  factory ExpertSystem.fromMap(Map<String, dynamic> map) {
    return ExpertSystem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      documentMetadata: DocumentMetadata.fromMap(map['documentMetadata']),
    );
  }
}