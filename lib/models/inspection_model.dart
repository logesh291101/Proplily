class PlanModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String duration;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String,
      features: List<String>.from(json['features'] as List? ?? []),
    );
  }
}

class Inspection {
  final String id;
  final String propertyId;
  final DateTime inspectionDate;
  final String summary;
  final String status;

  Inspection({
    required this.id,
    required this.propertyId,
    required this.inspectionDate,
    required this.summary,
    required this.status,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      inspectionDate: DateTime.parse(json['inspection_date'] as String),
      summary: json['summary'] as String,
      status: json['status'] as String,
    );
  }
}
