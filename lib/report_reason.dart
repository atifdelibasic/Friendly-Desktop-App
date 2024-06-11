
class ReportReason {
  final int id;
  final String description;

  ReportReason({
    required this.id,
    required this.description,
  });

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      id: json['id'] as int,
      description: json['description'] as String,
    );
  }
}