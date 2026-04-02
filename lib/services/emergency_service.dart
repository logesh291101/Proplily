import '../utils/preferences.dart';
import 'base_api_service.dart';

class EmergencyService extends BaseApiService {
  Future<bool> reportEmergency({
    required String propertyId,
    required String reason,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}user/emergency/request', {
        'property_id': propertyId,
        'reason': reason,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

class SupportService extends BaseApiService {
  Future<bool> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}user/support/submit', {
        'subject': subject,
        'category': category,
        'message': message,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
