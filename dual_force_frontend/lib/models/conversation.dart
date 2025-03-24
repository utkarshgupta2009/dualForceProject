import 'package:dual_force/models/message.dart';

class Conversation {
  final String? id;
  final String expertSystemId;
  final String userId;

  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;


  Conversation({
     this.id,
    required this.expertSystemId,
    required this.userId,
  
    required this.createdAt,
    required this.updatedAt,
    required this.messages,

  });

  Map<String, dynamic> toMap() {
    return {
       if (id != null) '_id': id, 
      'expertSystemId': expertSystemId,
      'userId': userId,
    
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'messages': messages.map((msg) => msg.toMap()).toList(),
     
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['_id'],
      expertSystemId: map['expertSystemId'],
      userId: map['userId'],
      
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      messages: List<Message>.from(
        map['messages']?.map((x) => Message.fromMap(x)) ?? [],
      ),

    );
  }
}
