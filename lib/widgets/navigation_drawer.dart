import 'package:desktop_friendly_app/screens/cities_screen.dart';
import 'package:desktop_friendly_app/screens/countries_screen.dart';
import 'package:desktop_friendly_app/screens/hobby_category_screen.dart';
import 'package:desktop_friendly_app/screens/hobby_screen.dart';
import 'package:desktop_friendly_app/screens/rate_app_screen.dart';
import 'package:desktop_friendly_app/screens/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_profile_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/login_screen.dart';
import '../screens/users_screen.dart';
import '../shared_preference.dart';
import '../user_provider.dart';


class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);


  void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async{
              await UserPreferences().removeUser();
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
        );
            },
            child: Text("Logout"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).user;


    return Drawer(
      child: Material(
        color: Colors.deepPurple,
        child: ListView(
          children: <Widget>[
            buildHeader(
              urlImage: user!.profileImage,
              name: "${user!.firstName} ${user.lastName}",
              email: user.email,
              
              onClicked: () => {
                 Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: user),
                ),
              ),
              },
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Users',
                    icon: Icons.people,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Countries',
                    icon: Icons.location_on_rounded,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Cities',
                    icon: Icons.location_city,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Reports',
                    icon: Icons.bug_report,
                    onClicked: () => selectedItem(context, 3),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Feedback',
                    icon: Icons.feedback,
                    onClicked: () => selectedItem(context, 4),
                  ),
                   const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Rate app reviews',
                    icon: Icons.rate_review,
                    onClicked: () => selectedItem(context, 6),
                  ),
                  const SizedBox(height: 24),
                   buildMenuItem(
                    text: 'Hobby Categories',
                    icon: Icons.category,
                    onClicked: () => selectedItem(context, 7),
                  ),
                   const SizedBox(height: 24),
                   buildMenuItem(
                    text: 'Hobbies',
                    icon: Icons.sports_football,
                    onClicked: () => selectedItem(context, 8),
                  ),
                  Divider(color: Colors.white70),

                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Logout',
                    icon: Icons.logout,
                    onClicked: () => selectedItem(context, 5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            
            ],
          ),
        ),
      );

  Widget buildSearchField() {
    final color = Colors.white;

    return TextField(
      style: TextStyle(color: color),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        hintText: 'Search',
        hintStyle: TextStyle(color: color),
        prefixIcon: Icon(Icons.search, color: color),
        filled: true,
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Home(),
        ));
        break;
        case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CountriesScreen(),
        ));
        break;
        case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CitiesScreen(),
        ));
        break;
        case 3:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ReportsScreen(),
        ));
        case 4:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FeedbackScreen(),
        ));
        break;
        case 5:
        _showLogoutConfirmationDialog(context);
        break;
         case 6:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RateAppScreen(),
        ));
        case 7:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HobbyCategoryScreen(),
        ));
         case 8:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HobbyScreen(),
        ));
    }
  }
}