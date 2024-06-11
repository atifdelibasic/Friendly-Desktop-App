import 'package:desktop_friendly_app/domain/rateapp.dart';

class RateAppResponse{
  final List<RateApp> rateapp;
  final int count;

  RateAppResponse({required this.rateapp, required this.count});

  factory RateAppResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<RateApp> rateappList = list.map((i) => RateApp.fromJson(i)).toList();
    return RateAppResponse(
      rateapp: rateappList,
      count: json['count'] as int,
    );
  }
}