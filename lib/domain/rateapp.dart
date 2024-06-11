import '../user.dart';

class RateApp {
  final int id;
  final double rating;
  final User user;
  final String dateCreated;

  RateApp({
    required this.id,
    required this.user,
    required this.rating,
    required this.dateCreated
  });

  factory RateApp.fromJson(Map<String, dynamic> json) {
    return RateApp(
      id: json['id'] as int,
      rating: (json['rating'] as num).toDouble(), // Convert to double explicitly
      dateCreated: json['dateCreated'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
