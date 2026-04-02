class MaintenanceRequest {
  final String id;
  final String propertyId;
  final String description;
  final List<String> photos;
  final String status;
  final double? cost;
  final DateTime createdAt;

  MaintenanceRequest({
    required this.id,
    required this.propertyId,
    required this.description,
    required this.photos,
    required this.status,
    this.cost,
    required this.createdAt,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      description: json['description'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      status: json['status'] as String,
      cost: (json['cost'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String contactInfo;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.contactInfo,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      serviceType: json['service_type'] as String,
      contactInfo: json['contact_info'] as String,
    );
  }
}
