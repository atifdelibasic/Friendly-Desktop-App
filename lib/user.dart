
class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String token;
  String? fullName;
  String profileImage;
  String description;
  String? birthDate;
  List<dynamic> roles;
  String dateCreated;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.profileImage,
    required this.description,
    this.birthDate,
    this.fullName,
    required this.roles,
    required this.dateCreated
  });

  factory User.fromJson(Map<String, dynamic> responseData) {
    String firstName = responseData['firstName'] ?? "";
    String lastName = responseData['lastName'] ?? "";

      String profileImageUrl = 'https://ui-avatars.com/api/?rounded=true&name=ad&size=300';
    if(responseData['profileImageUrl'] != null) {
      profileImageUrl = 'http://localhost:7169/images/' + responseData['profileImageUrl'] as String;
    }

    return User(
      id: responseData['id'] ?? 0,
      firstName: responseData['firstName'] ?? "",
      lastName: responseData['lastName'] ?? "",
      email: responseData['email'] ?? "" ,
      token: responseData['token'] ?? "" ,
      fullName: "$firstName $lastName",
      profileImage: 'https://ui-avatars.com/api/?rounded=true&name=ad&size=300',
      description: responseData['description'] ?? "",
      birthDate: responseData["birthDate"],
      roles: responseData["roles"] ?? [],
      dateCreated: responseData["dateCreated"],
    );
  }
}
