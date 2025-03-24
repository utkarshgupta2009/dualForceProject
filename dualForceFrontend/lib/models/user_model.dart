import 'package:dual_force/models/expert_system.dart';

class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final List<ExpertSystem> expertSystems;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.expertSystems,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'expertSystems': expertSystems.map((es) => es.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
      expertSystems: List<ExpertSystem>.from(
        map['expertSystems']?.map((x) => ExpertSystem.fromMap(x)) ?? [],
      ),
    );
  }
}