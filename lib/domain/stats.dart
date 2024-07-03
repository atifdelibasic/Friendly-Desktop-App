import 'package:desktop_friendly_app/domain/user_post_count.dart';

class Stats {
  final int totalPostsCount;
  final int totalRateAppCount;
  final int totalFeedbackCount;
  final int totalReportCount;
  final int totalPostsTodayCount;
  final int totalReportCountToday;
  final int totalFeedbackCountToday;
  final int totalRateAppCountToday;
  final int totalUsersCount;
  final int totalUsersTodayCount;
  final List<UserPostCount> getTopActiveUsers;
  final double postGrowthRate;
  final double allTimeAppRating;
  final int deletedUsersCount;

  Stats({
    required this.totalPostsCount,
    required this.totalRateAppCount,
    required this.totalFeedbackCount,
    required this.totalReportCount,
    required this.totalPostsTodayCount,
    required this.totalReportCountToday,
    required this.totalFeedbackCountToday,
    required this.totalRateAppCountToday,
    required this.totalUsersCount,
    required this.totalUsersTodayCount,
    required this.getTopActiveUsers,
    required this.postGrowthRate,
    required this.allTimeAppRating,
    required this.deletedUsersCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalPostsCount: json['totalPostsCount'],
      totalRateAppCount: json['totalRateAppCount'],
      totalFeedbackCount: json['totalFeedbackCount'],
      totalReportCount: json['totalReportCount'],
      totalPostsTodayCount: json['totalPostsTodayCount'],
      totalReportCountToday: json['totalReportCountToday'],
      totalFeedbackCountToday: json['totalFeedbackCountToday'],
      totalRateAppCountToday: json['totalRateAppCountToday'],
      totalUsersCount: json['totalUsersCount'],
      deletedUsersCount: json['deletedUsersCount'],
      totalUsersTodayCount: json['totalUsersTodayCount'],
      allTimeAppRating: json['allTimeAppRating']?.toDouble() ?? 0.0,
      postGrowthRate: json['postGrowthRate']?.toDouble() ?? 0.0,
      getTopActiveUsers: (json['getTopActiveUsers'] as List)
          .map((i) => UserPostCount.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPostsCount': totalPostsCount,
      'totalRateAppCount': totalRateAppCount,
      'totalFeedbackCount': totalFeedbackCount,
      'totalReportCount': totalReportCount,
      'totalPostsTodayCount': totalPostsTodayCount,
      'totalReportCountToday': totalReportCountToday,
      'totalFeedbackCountToday': totalFeedbackCountToday,
      'totalRateAppCountToday': totalRateAppCountToday,
      'totalUsersCount': totalUsersCount,
      'totalUsersTodayCount': totalUsersTodayCount,
      'postGrowthRate': postGrowthRate,
      'allTimeAppRating': allTimeAppRating,
      'getTopActiveUsers': getTopActiveUsers.map((e) => e.toJson()).toList(),
      'deletedusersCount': deletedUsersCount
    };
  }
}
