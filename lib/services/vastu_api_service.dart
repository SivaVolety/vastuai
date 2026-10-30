import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'api_config.dart';

class VastuApiException implements Exception {
  final String message;
  VastuApiException(this.message);
  @override
  String toString() => message;
}

class VastuApiService {
  VastuApiService({http.Client? client}) : _client = client;
  final http.Client? _client;
  static const _timeout = Duration(seconds: 30);

  static Map<String, dynamic> parseAnalysisResponse(String body) {
    final data = jsonDecode(body);
    if (data is! Map || data['image_url'] is! String || data['vastu_report'] is! List) {
      throw const FormatException('Backend returned an invalid analysis response.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> testConnection() async {
    final base = await ApiConfig.getBaseUrl();
    try {
      final response = await (_client?.get(Uri.parse('$base/health')) ??
          http.get(Uri.parse('$base/health'))).timeout(_timeout);
      if (response.statusCode != 200) {
        throw VastuApiException('Backend returned HTTP ${response.statusCode}.');
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data['status'] != 'ok') {
        throw VastuApiException('Backend returned an unexpected health response.');
      }
    } on FormatException catch (e) {
      throw VastuApiException(e.message);
    } on SocketException {
      throw VastuApiException('Backend is unreachable. Check the server address and network.');
    } on HttpException {
      throw VastuApiException('Unable to connect to the backend.');
    } on VastuApiException {
      rethrow;
    } catch (e) {
      throw VastuApiException('Connection test failed: $e');
    }
  }

  Future<Map<String, dynamic>> upload(File file, {
    required String ruleSetName,
    required Map<String, List<String>> rules,
    double confidenceThreshold = 0.25,
    bool showBoundingBoxes = true,
    String modelVersion = 'v1',
  }) async {
    return uploadBytes(await file.readAsBytes(),
        filename: file.uri.pathSegments.last,
        ruleSetName: ruleSetName,
        rules: rules,
        confidenceThreshold: confidenceThreshold,
        showBoundingBoxes: showBoundingBoxes,
        modelVersion: modelVersion);
  }

  Future<Map<String, dynamic>> uploadBytes(Uint8List bytes, {
    String filename = 'floor-plan.png',
    required String ruleSetName,
    required Map<String, List<String>> rules,
    double confidenceThreshold = 0.25,
    bool showBoundingBoxes = true,
    String modelVersion = 'v1',
  }) async {
    if (modelVersion != 'v1' && modelVersion != 'v2') {
      throw VastuApiException('Choose a supported model: v1 or v2.');
    }
    final base = await ApiConfig.getBaseUrl();
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$base/upload-rotated'));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      request.fields['rule_set_name'] = ruleSetName;
      request.fields['rules'] = jsonEncode(rules);
      request.fields['confidence_threshold'] = confidenceThreshold.toString();
      request.fields['show_bounding_boxes'] = showBoundingBoxes.toString();
      request.fields['model_version'] = modelVersion;
      final response = await (_client?.send(request) ?? request.send()).timeout(_timeout);
      final body = await http.Response.fromStream(response);
      if (body.statusCode < 200 || body.statusCode >= 300) {
        final kind = body.statusCode >= 500 ? 'Backend error' : 'Request rejected';
        throw VastuApiException('$kind (HTTP ${body.statusCode}).');
      }
      try {
        return parseAnalysisResponse(body.body);
      } on FormatException catch (e) {
        throw VastuApiException(e.message);
      }
    } on FormatException catch (e) {
      throw VastuApiException(e.message);
    } on SocketException {
      throw VastuApiException('Backend is unreachable. Check the server address and network.');
    } on TimeoutException {
      throw VastuApiException('The backend request timed out.');
    } on VastuApiException {
      rethrow;
    } catch (e) {
      throw VastuApiException('Analysis failed: $e');
    }
  }
}
