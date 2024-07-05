import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_url.dart';
import '../domain/stats.dart';
import '../shared_preference.dart';

class StatsService {

  Future<Stats> fetchStats() async {
    var token = await UserPreferences().getToken();
    
    final response = await http.get(
      Uri.parse('${AppUrl.baseUrl}/Stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization' : 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Stats.fromJson(json);
    } else {
      print("status code" + response.statusCode.toString());
      print(token);
      throw Exception('Failed to load stats');
    }
  }
}
