import 'hobby.dart';
 
class HobbyResponse{
  final List<Hobby> hobbies;
  final int count;

  HobbyResponse({required this.hobbies, required this.count});

  factory HobbyResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Hobby> hobbies = list.map((i) => Hobby.fromJson(i)).toList();
    return HobbyResponse(
      hobbies: hobbies,
      count: json['count'] as int,
    );
  }
}