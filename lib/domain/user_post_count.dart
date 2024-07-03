class UserPostCount {
  final int userId;
  final String username;
  final int postCount;

  UserPostCount({
    required this.userId,
    required this.username,
    required this.postCount,
  });

  factory UserPostCount.fromJson(Map<String, dynamic> json) {
    return UserPostCount(
      userId: json['userId'],
      username: json['username'],
      postCount: json['postCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'postCount': postCount,
    };
  }
}
