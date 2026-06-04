/// Result of registering a property asset.
sealed class PropertyRegistrationResult {
  const PropertyRegistrationResult();
}

final class PropertyRegistrationSuccess extends PropertyRegistrationResult {
  const PropertyRegistrationSuccess({
    this.message = 'Property registered successfully.',
  });

  final String message;
}

final class PropertyRegistrationFailure extends PropertyRegistrationResult {
  const PropertyRegistrationFailure({required this.message});

  final String message;
}

/// Handles property registration API calls.
class PropertyService {
  PropertyService();

  Future<PropertyRegistrationResult> registerProperty({
    required String propertyName,
    required String plotType,
    required String plotSize,
    required String country,
    required String state,
    required String city,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String ownerName,
    required String phoneNumber,
    required List<String> documentPaths,
    required List<String> imagePaths,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const PropertyRegistrationSuccess();
  }
}
