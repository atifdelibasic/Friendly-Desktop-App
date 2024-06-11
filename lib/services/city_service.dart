import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/country_response.dart';
import 'package:http/http.dart' as http;
import '../city.dart';
import '../city_response.dart';
import '../shared_preference.dart';

class CityService {
  final String baseUrl;

  CityService({required this.baseUrl});

  Future<CityResponse> fetchCities(String searchText,  int currentPage) async {
    String uri = '${AppUrl.baseUrl}/city?page=${currentPage - 1}&PageSize=10';
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
      List<City> cities = jsonList.map((json) => City.fromJson(json as Map<String, dynamic>)).toList();
       int count = responseBody['count'] as int;
       print("count " + count.toString());


      return CityResponse(cities: cities, count: count);
    } else {
      print("error");
      throw Exception('Failed to load countries');
    }
  }

  Future<City> fetchCity(int id) async {
    final response = await http.get(Uri.parse('${AppUrl.baseUrl}/city/$id'));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      City country = City.fromJson(json);
      return country;
    } else {
      throw Exception('Failed to load country');
    }
  }
}
