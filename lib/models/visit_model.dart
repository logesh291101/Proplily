enum VisitStatus {
  notStarted,
  started,
  completed,
  missed,
}

class Visit {
  final String id;
  final String propertyId;
  final String coordinatorId;
  final DateTime? scheduledDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final List<String> geoTaggedImages;
  final String? startNotes;
  final String? visitRemarks;
  final VisitStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Visit({
    required this.id,
    required this.propertyId,
    required this.coordinatorId,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.geoTaggedImages = const [],
    this.startNotes,
    this.visitRemarks,
    this.status = VisitStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      coordinatorId: json['coordinatorId'] as String,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      startLatitude: json['startLatitude'] != null
          ? (json['startLatitude'] as num).toDouble()
          : null,
      startLongitude: json['startLongitude'] != null
          ? (json['startLongitude'] as num).toDouble()
          : null,
      endLatitude: json['endLatitude'] != null
          ? (json['endLatitude'] as num).toDouble()
          : null,
      endLongitude: json['endLongitude'] != null
          ? (json['endLongitude'] as num).toDouble()
          : null,
      geoTaggedImages:
          List<String>.from(json['geoTaggedImages'] as List? ?? []),
      startNotes: json['startNotes'] as String?,
      visitRemarks: json['visitRemarks'] as String?,
      status: VisitStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => VisitStatus.notStarted,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'coordinatorId': coordinatorId,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'geoTaggedImages': geoTaggedImages,
      'startNotes': startNotes,
      'visitRemarks': visitRemarks,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
