import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/providers/advanced_settings_provider.dart';
import 'package:vastuai/services/vastu_api_service.dart';
import 'package:vastuai/models/analysis_history_entry.dart';
import 'package:vastuai/services/analysis_history_service.dart';

void main() {
  test('advanced settings use historical defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AdvancedSettingsProvider();
    await settings.load();
    expect(settings.confidenceThreshold, 0.25);
    expect(settings.showConfidence, isFalse);
    expect(settings.showBoundingBoxes, isTrue);
  });

  test('advanced settings persist and reset', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AdvancedSettingsProvider();
    await settings.setConfidence(0.7);
    await settings.setShowConfidence(true);
    await settings.setShowBoundingBoxes(false);
    expect((await SharedPreferences.getInstance()).getDouble('detection_confidence'), 0.7);
    await settings.reset();
    expect(settings.confidenceThreshold, 0.25);
    expect(settings.showConfidence, isFalse);
    expect(settings.showBoundingBoxes, isTrue);
  });

  test('analysis response accepts confidence and legacy missing confidence', () {
    final withConfidence = VastuApiService.parseAnalysisResponse(jsonEncode({
      'image_url': '/outputs/a.jpg', 'vastu_report': [{'label': 'bed', 'confidence': 0.8}],
    }));
    final legacy = VastuApiService.parseAnalysisResponse(jsonEncode({
      'image_url': '/outputs/a.jpg', 'vastu_report': [{'label': 'bed'}],
    }));
    expect(withConfidence['vastu_report'][0]['confidence'], 0.8);
    expect(legacy['vastu_report'][0]['confidence'], isNull);
  });

  test('analysis response preserves optional rule_applied and legacy omission', () {
    final covered = VastuApiService.parseAnalysisResponse(jsonEncode({
      'image_url': '/outputs/a.jpg',
      'vastu_report': [{'label': 'sink', 'vastu_ok': true, 'rule_applied': true}],
    }));
    final uncovered = VastuApiService.parseAnalysisResponse(jsonEncode({
      'image_url': '/outputs/a.jpg',
      'vastu_report': [{'label': 'bed', 'vastu_ok': false, 'rule_applied': false}],
    }));
    final legacy = VastuApiService.parseAnalysisResponse(jsonEncode({
      'image_url': '/outputs/a.jpg',
      'vastu_report': [{'label': 'bed', 'vastu_ok': false}],
    }));
    expect(covered['vastu_report'][0]['rule_applied'], isTrue);
    expect(uncovered['vastu_report'][0]['rule_applied'], isFalse);
    expect(legacy['vastu_report'][0]['rule_applied'], isNull);
  });

  test('history entries serialize, summarize, order, and retain 25 newest', () {
    final now = DateTime(2025, 1, 1);
    final entries = List.generate(26, (index) => AnalysisHistoryEntry(
      id: '$index', timestamp: now.add(Duration(days: index)), ruleSetName: 'Rules',
      imagePath: '/tmp/$index.jpg', report: const [{'vastu_ok': true}, {'vastu_ok': false}],
    ));
    final restored = AnalysisHistoryEntry.fromJson(entries.last.toJson());
    expect(restored.passedCount, 1);
    expect(restored.failedCount, 1);
    final fengShui = AnalysisHistoryEntry(
      id: 'feng', timestamp: now, ruleSetName: 'Feng Shui Compass Preset',
      imagePath: '/tmp/feng.jpg', report: const [
        {'vastu_ok': false, 'rule_applied': false},
        {'vastu_ok': true, 'rule_applied': true},
      ],
    );
    expect(fengShui.passedCount, 1);
    expect(fengShui.failedCount, 0);
    final retained = AnalysisHistoryService.retainNewest(entries);
    expect(retained, hasLength(25));
    expect(retained.first.id, '25');
    expect(retained.last.id, '1');
  });
}
