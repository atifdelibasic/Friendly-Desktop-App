class HobbyCategory {
  int id;
  String name;
  String dateCreated;

  HobbyCategory({
    required this.id,
    required this.name,
    required this.dateCreated
  });

  factory HobbyCategory.fromJson(Map<String, dynamic> json) {
    return HobbyCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      dateCreated: json['dateCreated'] as String,
    );
  }
}
