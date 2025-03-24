
class Message {
  final bool user;
  final String content;

 

  Message({
    required this.user,
    required this.content,

  });

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'content': content,
      
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      user: map['user'],
      content: map['content'],
      
    );
  }
}