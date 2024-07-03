import 'package:desktop_friendly_app/domain/hobby_category.dart';
 
class HobbyCategoryResponse{
  final List<HobbyCategory> hobbyCategories;
  final int count;

  HobbyCategoryResponse({required this.hobbyCategories, required this.count});

  factory HobbyCategoryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<HobbyCategory> hobbyCategories = list.map((i) => HobbyCategory.fromJson(i)).toList();
    return HobbyCategoryResponse(
      hobbyCategories: hobbyCategories,
      count: json['count'] as int,
    );
  }
}