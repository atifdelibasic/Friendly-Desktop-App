import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/domain/rateapp.dart';
import 'package:desktop_friendly_app/domain/rateapp_response.dart';
import 'package:http/http.dart' as http;
import '../shared_preference.dart';

class RateAppService {
  final String baseUrl;

  RateAppService({required this.baseUrl});

  Future<RateAppResponse> fetchRates(String searchText,  int currentPage) async {
    String uri = '${AppUrl.baseUrl}/rateapp?page=${currentPage - 1}&PageSize=10';
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
      List<RateApp> rateAppList = jsonList.map((json) => RateApp.fromJson(json as Map<String, dynamic>)).toList();
       int count = responseBody['count'] as int;


      return RateAppResponse(rateapp: rateAppList, count: count);
    } else {
      print("error");
      throw Exception('Failed to load countries');
    }
  }
  
}
