import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/shared_preference.dart';
import 'package:http/http.dart' as http;
import '../report.dart';
import '../report_response.dart';

class ReportsService {
  final String baseUrl;

  ReportsService({required this.baseUrl});

  Future<ReportResponse> fetchReports(
      String searchText, int currentPage) async {
    String uri = '${AppUrl.baseUrl}/report?page=${currentPage - 1}&PageSize=10';
    var token = await UserPreferences().getToken();

    if (searchText.isNotEmpty) {
      uri += '&text=$searchText';
    }

    final response = await http.get(
      Uri.parse(uri),
      headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
    );


    if (response.statusCode == 200) {
       Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      ReportResponse reportResponse = ReportResponse.fromJson(responseBody);
      return reportResponse;
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<Report> fetchReport(int id) async {
    final response = await http.get(Uri.parse('${AppUrl.baseUrl}/reports/$id'));

    if (response.statusCode == 200) {
      Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      Report report = Report.fromJson(json);
      return report;
    } else {
      throw Exception('Failed to load report');
    }
  }

  Future<void> markReportAsSeen(int reportId) async {
    print("report id " + reportId.toString());
    var token = await UserPreferences().getToken();


    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/report/seen?id=' + reportId.toString()),
      headers: {  'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          },
    );

    print("status codee " +  response.statusCode.toString());
    if (response.statusCode != 200) {
      throw Exception('Failed to mark post as seen');
    } else {
      print("success");
    }
  }
}
