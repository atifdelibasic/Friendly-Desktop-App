import 'package:desktop_friendly_app/screens/statistics_screen.dart';
import 'package:desktop_friendly_app/shared_preference.dart';
import 'package:desktop_friendly_app/user.dart';
import 'package:desktop_friendly_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_proivder.dart';
import 'screens/login_screen.dart';
import 'user_provider.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(
     MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
    child:   MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<User> getUserData() => UserPreferences().getUser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false
      ),
      home: FutureBuilder(
            future: getUserData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else if (snapshot.data?.token == "")
                    return Login();
                  else

                    Provider.of<UserProvider>(context).setUser(snapshot.data);
                    return MainPage();
              }
            })
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text("Friendly - Admin Panel"),
        ),
        body: Builder(
          builder: (context) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: StatisticsScreen()
          ),
        ),
      );
}