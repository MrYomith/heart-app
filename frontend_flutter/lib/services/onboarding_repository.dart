import 'package:dio/dio.dart';

import 'api_client.dart';
import 'auth_repository.dart' show ApiException;

class Hospital {
  final String id;
  final String name;
  final String? city;
  final String type; // hospital | rehab_centre
  const Hospital({required this.id, required this.name, this.city, required this.type});
  factory Hospital.fromJson(Map<String, dynamic> j) =>
      Hospital(id: j['id'], name: j['name'], city: j['city'], type: j['type']);
}

String _err(Response? r) {
  if (r?.data is Map && (r!.data as Map)['detail'] != null) return (r.data as Map)['detail'].toString();
  return 'Something went wrong. Please try again.';
}

class OnboardingRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Hospital>> hospitals() async {
    try {
      final r = await _dio.get('/api/hospitals');
      if (r.statusCode == 200) {
        return (r.data as List).map((e) => Hospital.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(_err(r));
    } on DioException catch (e) {
      throw ApiException(_err(e.response));
    }
  }

  /// Returns the resulting enrollment status: approved | pending.
  Future<String> enrollByCode(String code) async {
    try {
      final r = await _dio.post('/api/enrollment/by-code', data: {'code': code});
      if (r.statusCode == 200) return r.data['status'] as String;
      throw ApiException(_err(r));
    } on DioException catch (e) {
      throw ApiException(_err(e.response));
    }
  }

  Future<String> requestHospital(String hospitalId) async {
    try {
      final r = await _dio.post('/api/enrollment/request', data: {'hospital_id': hospitalId});
      if (r.statusCode == 200) return r.data['status'] as String;
      throw ApiException(_err(r));
    } on DioException catch (e) {
      throw ApiException(_err(e.response));
    }
  }

  /// Finalize onboarding. Returns the GAD-7 result map (or null).
  Future<Map<String, dynamic>?> complete({
    String? surgeryType,
    String? surgeryDate,
    String? nyhaClass,
    String? diagnosis,
    List<String> conditions = const [],
    List<String> allergies = const [],
    List<int> gad7Answers = const [],
  }) async {
    try {
      final r = await _dio.post('/api/onboarding/complete', data: {
        'surgery_type': surgeryType,
        'surgery_date': surgeryDate,
        'nyha_class': nyhaClass,
        'diagnosis': diagnosis,
        'conditions': conditions,
        'allergies': allergies,
        'gad7_answers': gad7Answers,
      });
      if (r.statusCode == 200) return r.data['gad7'] as Map<String, dynamic>?;
      throw ApiException(_err(r));
    } on DioException catch (e) {
      throw ApiException(_err(e.response));
    }
  }
}
