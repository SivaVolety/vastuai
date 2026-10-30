import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const defaultBaseUrl = String.fromEnvironment(
    'VASTUAI_API_BASE_URL',
    // Keep the former define usable for existing mobile development builds.
    defaultValue: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000',
    ),
  );
  static const _overrideKey = 'api_base_url';

  static String normalize(String value) {
    var url = value.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return normalize(prefs.getString(_overrideKey) ?? defaultBaseUrl);
  }

  static Future<void> saveBaseUrl(String value) async {
    final normalized = normalize(value);
    if (normalized.isEmpty) throw const FormatException('URL cannot be empty');
    final uri = Uri.tryParse(normalized);
    if (uri == null || !const ['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
      throw const FormatException('Enter a valid URL, including http:// or https://');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_overrideKey, normalized);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_overrideKey);
  }
}
