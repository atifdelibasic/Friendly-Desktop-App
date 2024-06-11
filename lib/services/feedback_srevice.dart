import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:http/http.dart' as http;
import '../domain/feedback.dart';
import '../domain/feedback_response.dart';
import '../shared_preference.dart';

class FeedbackService {
  final String baseUrl;

  FeedbackService({required this.baseUrl});

  Future<FeedbackResponse> fetchFeedbacks(String searchText,  int currentPage) async {
    String uri = '${AppUrl.baseUrl}/feedback?page=${currentPage - 1}&PageSize=10';
    var token = await UserPreferences().getToken();


    if (searchText != null && searchText.isNotEmpty) {
      uri += '&text=$searchText';
    }

    final response = await http.get(Uri.parse(uri),  headers: {
        'Authorization': 'Bearer $token',
      },);

      print(response.statusCode);

    if (response.statusCode == 200) {

      Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> jsonList = responseBody['result'] as List<dynamic>;
      List<FeedbackCustom> feedbacks = jsonList.map((json) => FeedbackCustom.fromJson(json as Map<String, dynamic>)).toList();
       int count = responseBody['count'] as int;


      return FeedbackResponse(feedbacks: feedbacks, count: count);
    } else {
      print("error");
      throw Exception('Failed to load countries');
    }
  }
  
}
