import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/domain/hobby_response.dart';
import 'package:http/http.dart' as http;
import '../domain/hobby.dart';
import '../shared_preference.dart';

class HobbyService {
  final String baseUrl;

  HobbyService({required this.baseUrl});

  Future<HobbyResponse> fetchHobby(String searchText,  int currentPage, int limit) async {
    String uri = '${AppUrl.baseUrl}/hobby?page=${currentPage - 1}&PageSize=$limit';

    var token = await UserPreferences().getToken();

    if (searchText.isNotEmpty) {
      uri += '&text=$searchText';
    }

    final response = await http.get(Uri.parse(uri),  headers: {
        'Authorization': 'Bearer $token',
      },);

    if (response.statusCode == 200) {

      Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> jsonList = responseBody['result'] as List<dynamic>;
      List<Hobby> hobbies = jsonList.map((json) => Hobby.fromJson(json as Map<String, dynamic>)).toList();
      int count = responseBody['count'] as int;


      return HobbyResponse(hobbies: hobbies, count: count);
    } else {
      throw Exception('Failed to load countries');
    }
  }

}
