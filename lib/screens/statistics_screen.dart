import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/user_post_count.dart';
import '../services/stats_service.dart';
import '../domain/stats.dart';
import '../widgets/leaderboard.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatsService _statsService = StatsService();
  late Future<Stats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _statsService.fetchStats();
  }

  Future<void> _refreshData() async {
    setState(() {
      _statsFuture = _statsService.fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Stats>(
          future: _statsFuture,
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Leaderboard(
                      topActiveUsers: stats.getTopActiveUsers.map((user) {
                        return UserPostCount(
                          userId: user.userId,
                          username: user.username,
                          postCount: user.postCount,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildStatCard(
                      'User Statistics',
                      [
                        _buildStat('Total Users', stats.totalUsersCount.toString(), Icons.people, Colors.deepOrange),
                        _buildStat('New Registrations Today', stats.totalUsersTodayCount.toString(), Icons.person_add, Colors.deepOrange),
                        _buildStat('Deleted/Deactivated accounts', stats.deletedUsersCount.toString(), Icons.person_add, Colors.deepOrange),
                      ],
                      Colors.deepOrange
                    ),
                    const SizedBox(height: 32),
                    _buildStatCard(
                      'Post Statistics',
                      [
                        _buildStat('Posts Today', stats.totalPostsTodayCount.toString(), Icons.article, Colors.pink),
                        _buildStat('Total Posts', stats.totalPostsCount.toString(), Icons.article_outlined, Colors.pink),
                        _buildStat('Posts Growth Rate (previous month)', "${stats.postGrowthRate}", Icons.percent_rounded, Colors.pink),
                      ],
                      Colors.pink
                    ),
                    const SizedBox(height: 32),
                    _buildStatCard(
                      'Report Statistics',
                      [
                        _buildStat('Reports Today', stats.totalReportCountToday.toString(), Icons.dangerous, Colors.indigo),
                        _buildStat('Reports Total', stats.totalReportCount.toString(), Icons.dangerous_outlined, Colors.indigo),
                      ],
                      Colors.indigo
                    ),
                    const SizedBox(height: 32),
                    _buildStatCard(
                      'RateApp Statistics',
                      [
                        _buildStat('RateApp Today', stats.totalRateAppCountToday.toString(), Icons.star, Colors.teal),
                        _buildStat('RateApp Total', stats.totalRateAppCount.toString(), Icons.star_border_outlined, Colors.teal),
                        _buildStat('All time app rating', stats.allTimeAppRating.toString(), Icons.timelapse_rounded, Colors.teal),
                      ],
                      Colors.teal
                    ),
                    const SizedBox(height: 32),
                     _buildStatCard(
                      'Feedback Statistics',
                      [
                        _buildStat('Feedback Today', stats.totalFeedbackCountToday.toString(), Icons.star,Colors.red),
                        _buildStat('Feedback Total', stats.totalFeedbackCount.toString(), Icons.star_border_outlined, Colors.red),
                      ],
                      Colors.red
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> stats, MaterialColor color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 16),
            ...stats,
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData iconData, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
