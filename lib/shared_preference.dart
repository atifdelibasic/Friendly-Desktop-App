
import 'package:desktop_friendly_app/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('firstName', user.firstName);
    prefs.setString('lastName', user.lastName);
    prefs.setString('email', user.email);
    prefs.setString('token', user.token);
    prefs.setInt('id', user.id);
    prefs.setString('profileImageUrl', user.profileImage);
    prefs.setString('birthDate', user.birthDate ?? "");
    prefs.setString('dateCreated', user.dateCreated);

    return await prefs.setBool('loggedIn', true);
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("id") ?? 0;
    String firstName = prefs.getString("firstName") ?? "";
    String email = prefs.getString("email") ?? "";
    String lastName = prefs.getString("lastName") ?? "";
    String token = prefs.getString("token") ?? "";
    String profileImageUrl = prefs.getString("profileImageUrl") ?? "";
    String birthDate = prefs.getString("birthDate") ?? "";
    List<String> roles = prefs.getStringList("roles") ?? [];
    String dateCreated = prefs.getString("dateCreated") ?? "";

    return User(
        id: id,
        firstName: firstName,
        email: email,
        lastName: lastName,
        token: token,
        profileImage: profileImageUrl,
        description: "",
        birthDate: birthDate,
        roles: roles,
        dateCreated: dateCreated
       );
  }

  Future<void> removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('id');
    await prefs.remove('lastName');
    await prefs.remove('email');
    await prefs.remove('firstName');
    await prefs.remove('token');
    await prefs.remove('profileImageUrl');
    await prefs.remove('birthDate');
    await prefs.remove('dateCreated');
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    return token;
  }
}
