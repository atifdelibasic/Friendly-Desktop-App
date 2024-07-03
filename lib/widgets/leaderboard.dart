import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/user_post_count.dart'; 

class Leaderboard extends StatelessWidget {
  final List<UserPostCount> topActiveUsers;

  Leaderboard({required this.topActiveUsers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Active Users',
            style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600  ,
                  ),    
          ),
          SizedBox(height: 16.0),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: topActiveUsers.length,
            itemBuilder: (context, index) {
              final user = topActiveUsers[index];
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0], style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600  ,
                  ),    ),
                  ),
                  title: Text(user.username),
                  subtitle: Text('${user.postCount} posts', style: GoogleFonts.montserrat(
                  fontSize: 12,
                ),),
                  trailing: Text('# ${index + 1}', style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
