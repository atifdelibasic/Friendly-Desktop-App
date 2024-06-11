import 'package:desktop_friendly_app/report.dart';

class ReportResponse {
  final List<Report> reports;
  final int count;

  ReportResponse({required this.reports, required this.count});

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Report> reportList = list.map((i) => Report.fromJson(i)).toList();
    return ReportResponse(
      reports: reportList,
      count: json['count'] as int,
    );
  }
}