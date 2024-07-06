import '../user.dart';

class FeedbackCustom {
  final int id;
  final String text;
  final User? user;
  final String dateCreated;

  FeedbackCustom({
    required this.id,
    required this.user,
    required this.text,
    required this.dateCreated
  });

  factory FeedbackCustom.fromJson(Map<String, dynamic> json) {
    return FeedbackCustom(
      id: json['id'] as int,
      text: json['text'] as String,
      dateCreated: json['dateCreated'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>): null
    );
  }
}

