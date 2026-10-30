import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/models/analysis_history_entry.dart';
import 'package:vastuai/models/detector_model.dart';
import 'package:vastuai/providers/model_selection_provider.dart';
import 'package:vastuai/services/analysis_history_service.dart';
import 'package:vastuai/services/api_config.dart';
import 'package:vastuai/services/vastu_api_service.dart';
import 'package:vastuai/widgets/model_selector.dart';

class RecordingClient extends http.BaseClient {
  http.MultipartRequest? upload;
  final String? reportedVersion;
  RecordingClient(this.reportedVersion);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    upload = request as http.MultipartRequest;
    return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({
          'image_url': '/outputs/a.jpg',
          'vastu_report': <Object>[],
          'rule_set_name': 'Custom',
          if (reportedVersion != null) 'model_version': reportedVersion,
        }))),
        200);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('API defaults honor the deployment define and retain Settings overrides',
      () async {
    const configured = String.fromEnvironment('VASTUAI_API_BASE_URL',
        defaultValue: String.fromEnvironment('API_BASE_URL',
            defaultValue: 'http://localhost:8000'));
    expect(await ApiConfig.getBaseUrl(), ApiConfig.normalize(configured));
    await ApiConfig.saveBaseUrl(' https://custom.example/ ');
    expect(await ApiConfig.getBaseUrl(), 'https://custom.example');
    await ApiConfig.reset();
    expect(await ApiConfig.getBaseUrl(), ApiConfig.normalize(configured));
    await expectLater(
        ApiConfig.saveBaseUrl('file:///tmp/api'), throwsFormatException);
  });

  for (final version in <String?>[null, 'v1', 'v2']) {
    test(
        'multipart upload sends ${version ?? 'default V1'} and preserves existing fields',
        () async {
      final expected = version ?? 'v1';
      final client = RecordingClient(expected);
      final service = VastuApiService(client: client);
      final result = await service.uploadBytes(Uint8List.fromList([1, 2, 3]),
          filename: 'plan.png',
          ruleSetName: 'Custom',
          rules: {
            'bed': ['N']
          },
          confidenceThreshold: 0.4,
          showBoundingBoxes: false,
          modelVersion: version ?? 'v1');
      expect(client.upload!.url.path, '/upload-rotated');
      expect(client.upload!.fields, {
        'rule_set_name': 'Custom',
        'rules': '{"bed":["N"]}',
        'confidence_threshold': '0.4',
        'show_bounding_boxes': 'false',
        'model_version': expected,
      });
      expect(client.upload!.files.single.field, 'file');
      expect(client.upload!.files.single.filename, 'plan.png');
      expect(result['model_version'], expected);
    });
  }

  test('uploadBytes defaults to stable V1', () async {
    final client = RecordingClient('v1');
    await VastuApiService(client: client)
        .uploadBytes(Uint8List(1), ruleSetName: 'Vastu Presets', rules: {});
    expect(client.upload!.fields['model_version'], 'v1');
  });

  test('older backend can omit model version without being mislabeled V2',
      () async {
    final service = VastuApiService(client: RecordingClient(null));
    final result = await service.uploadBytes(Uint8List(1),
        ruleSetName: 'Rules', rules: {}, modelVersion: 'v2');
    expect(result['model_version'], isNull);
    expect(DetectorModel.fromVersion(result['model_version']), isNull);
    expect(DetectorModel.fromVersion('v2'), DetectorModel.v2);
    expect(DetectorModel.fromVersion('future'), isNull);
  });

  test('history retains model version and supports old records', () {
    final entry = AnalysisHistoryEntry(
        id: '1',
        timestamp: DateTime(2026),
        ruleSetName: 'Rules',
        imagePath: '/saved.jpg',
        report: const [],
        modelVersion: 'v2');
    expect(AnalysisHistoryEntry.fromJson(entry.toJson()).modelVersion, 'v2');
    final legacy = entry.toJson()..remove('modelVersion');
    expect(AnalysisHistoryEntry.fromJson(legacy).modelVersion, isNull);
  });

  test('web history never invokes mobile filesystem storage', () async {
    final history = AnalysisHistoryService();
    expect(await history.load(), isEmpty);
    await history.clear();
    await history.delete('unused');
    expect(
        await history.saveRemoteResult(
            imageUrl: '/outputs/a.jpg',
            ruleSetName: 'Rules',
            report: [],
            confidenceThreshold: 0.25,
            showConfidence: false,
            showBoundingBoxes: true),
        isNull);
  }, skip: !kIsWeb);

  testWidgets(
      'selector defaults to V1 and retains V2 when recreated in the session',
      (tester) async {
    final selection = ModelSelectionProvider();
    Widget screen() => ChangeNotifierProvider.value(
        value: selection,
        child: const MaterialApp(home: Scaffold(body: ModelSelector())));
    await tester.pumpWidget(screen());
    expect(selection.selected, DetectorModel.v1);
    expect(find.text(DetectorModel.betaWarning), findsNothing);
    await tester.tap(find.byType(DropdownButton<DetectorModel>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(DetectorModel.v2.selectorLabel).last);
    await tester.pumpAndSettle();
    expect(selection.selected, DetectorModel.v2);
    expect(find.text(DetectorModel.betaWarning), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen());
    expect(find.text(DetectorModel.v2.selectorLabel), findsOneWidget);
    expect(ModelSelectionProvider().selected, DetectorModel.v1);
  });
}
