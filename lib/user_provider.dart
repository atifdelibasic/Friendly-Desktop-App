import 'package:desktop_friendly_app/shared_preference.dart';
import 'package:desktop_friendly_app/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  
  Future<void> initializeUser() async {
    _user = await UserPreferences().getUser();
    notifyListeners();
  }
}
