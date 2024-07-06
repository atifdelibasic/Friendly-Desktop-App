import 'package:desktop_friendly_app/post.dart';
import 'package:desktop_friendly_app/report_reason.dart';
import 'comment.dart';
import 'user.dart';

class Report {
  final int id;
  final String additionalComment;
  final User? user;
  final ReportReason reportReason;
  final String dateCreated;
  final Post? post;
  final Comment? comment;
  bool seen;

  Report({
    required this.id,
    required this.additionalComment,
    required this.user,
    required this.reportReason,
    required this.dateCreated,
    required this.comment,
    required this.post,
    required this.seen
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      seen: json['seen'] as bool,
      additionalComment: json['additionalComment'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>): null,
      reportReason: ReportReason.fromJson(json['reportReason'] as Map<String, dynamic>),
      dateCreated: json['dateCreated'] as String,
      post: json['post'] != null ? Post.fromJson(json['post'] as Map<String, dynamic>) : null, 
      comment: json['comment'] != null ? Comment.fromJson(json['comment'] as Map<String, dynamic>) : null,
    );
  }
}

