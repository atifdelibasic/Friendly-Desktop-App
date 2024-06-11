class Stats {
  final int totalPostsCount;
  final int totalPostsTodayCount;
  final int totalUsersCount;
  final int totalUsersTodayCount;

  Stats({
    required this.totalPostsCount,
    required this.totalPostsTodayCount,
    required this.totalUsersCount,
    required this.totalUsersTodayCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalPostsCount: json['totalPostsCount'],
      totalPostsTodayCount: json['totalPostsTodayCount'],
      totalUsersCount: json['totalUsersCount'],
      totalUsersTodayCount: json['totalUsersTodayCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPostsCount': totalPostsCount,
      'totalPostsTodayCount': totalPostsTodayCount,
      'totalUsersCount': totalUsersCount,
      'totalUsersTodayCount': totalUsersTodayCount,
    };
  }
}
