import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/domain/hobby_category.dart';
import 'package:http/http.dart' as http;
import '../domain/hobby_category_response.dart';
import '../shared_preference.dart';

class HobbyCategoryService {
  final String baseUrl;

  HobbyCategoryService({required this.baseUrl});

  Future<HobbyCategoryResponse> fetchHobbyCategories(String searchText,  int currentPage, int limit) async {
    String uri = '${AppUrl.baseUrl}/hobbycategory?page=${currentPage - 1}&PageSize=$limit';

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
      List<HobbyCategory> hobbyCategories = jsonList.map((json) => HobbyCategory.fromJson(json as Map<String, dynamic>)).toList();
      int count = responseBody['count'] as int;


      return HobbyCategoryResponse(hobbyCategories: hobbyCategories, count: count);
    } else {
      throw Exception('Failed to load countries');
    }
  }

}
