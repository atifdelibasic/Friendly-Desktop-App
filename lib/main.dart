import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as p;
import 'auth_proivder.dart';
import 'main_page.dart';
import 'screens/login_screen.dart';
import 'user.dart';
import 'user_provider.dart';
import 'shared_preference.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(create: (_) => AuthProvider()),
        p.ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<User> getUserData() => UserPreferences().getUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          p.Provider.of<UserProvider>(context, listen: false).initializeUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return MaterialApp(
            title: 'Friendly',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: false,
            ),
            home: p.Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null ||
                    userProvider.user?.token == "") {
                  return const Login();
                } else {
                  return MainPage();
                }
              },
            ),
          );
        }
      },
    );
  }
}
