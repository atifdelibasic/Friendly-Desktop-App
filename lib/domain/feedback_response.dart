import 'feedback.dart';

class FeedbackResponse {
  final List<FeedbackCustom> feedbacks;
  final int count;

  FeedbackResponse({required this.feedbacks, required this.count});

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<FeedbackCustom> feedbackList = list.map((i) => FeedbackCustom.fromJson(i)).toList();
    return FeedbackResponse(
      feedbacks: feedbackList,
      count: json['count'] as int,
    );
  }
}