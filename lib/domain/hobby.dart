class Hobby {
  int id;
  String title;
  String dateCreated;

  Hobby({
    required this.id,
    required this.title,
    required this.dateCreated
  });

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'] as int,
      title: json['title'] as String,
      dateCreated: json['dateCreated'] as String,
    );
  }
}
