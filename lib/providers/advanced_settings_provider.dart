import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSettingsProvider extends ChangeNotifier {
  static const defaultConfidence = 0.25;
  static const _confidenceKey = 'detection_confidence';
  static const _showConfidenceKey = 'show_detection_confidence';
  static const _showBoxesKey = 'show_bounding_boxes';

  double confidenceThreshold = defaultConfidence;
  bool showConfidence = false;
  bool showBoundingBoxes = true;
  bool loaded = false;

  AdvancedSettingsProvider() { load(); }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_confidenceKey);
    confidenceThreshold = value != null && value >= 0.1 && value <= 0.9
        ? value : defaultConfidence;
    showConfidence = prefs.getBool(_showConfidenceKey) ?? false;
    showBoundingBoxes = prefs.getBool(_showBoxesKey) ?? true;
    loaded = true;
    notifyListeners();
  }

  Future<void> setConfidence(double value) async {
    confidenceThreshold = value.clamp(0.1, 0.9).toDouble();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_confidenceKey, confidenceThreshold);
  }

  Future<void> setShowConfidence(bool value) async {
    showConfidence = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showConfidenceKey, value);
  }

  Future<void> setShowBoundingBoxes(bool value) async {
    showBoundingBoxes = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showBoxesKey, value);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_confidenceKey);
    await prefs.remove(_showConfidenceKey);
    await prefs.remove(_showBoxesKey);
    confidenceThreshold = defaultConfidence;
    showConfidence = false;
    showBoundingBoxes = true;
    notifyListeners();
  }
}
