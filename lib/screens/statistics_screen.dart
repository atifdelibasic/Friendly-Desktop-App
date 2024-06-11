import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import '../domain/stats.dart';

class StatisticsScreen extends StatelessWidget {
  final StatsService _statsService = StatsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Stats>(
        future: _statsService.fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final stats = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard(
                    'User Statistics',
                    [
                      _buildStat('Total Users', stats.totalUsersCount.toString(), Icons.people),
                      _buildStat('New Registrations Today', stats.totalUsersTodayCount.toString(), Icons.person_add),
                    ],
                  ),
                  SizedBox(height: 32),
                  _buildStatCard(
                    'Post Statistics',
                    [
                      _buildStat('Posts Today', stats.totalPostsTodayCount.toString(), Icons.article),
                      _buildStat('Total Posts', stats.totalPostsCount.toString(), Icons.article_outlined),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 16),
            ...stats,
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData iconData) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.blue),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
