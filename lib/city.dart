import 'country.dart';

class City {
  final int id;
  final String name;
  final Country country;
  final String dateCreated;
   String? deletedAt;  // Add the nullable deletedAt field

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.dateCreated,
    this.deletedAt,  
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      dateCreated: json['dateCreated'] as String,
      country: Country.fromJson(json['country'] as Map<String, dynamic>),
      deletedAt: json['deletedAt'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateCreated': dateCreated,
      'country': country.toJson(),
      'deletedAt': deletedAt,  
    };
  }
}
