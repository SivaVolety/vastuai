import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/analysis_history_entry.dart';

class AnalysisHistoryService {
  static const maxEntries = 25;
  static const _metadataFile = 'analysis_history.json';

  static List<AnalysisHistoryEntry> retainNewest(List<AnalysisHistoryEntry> entries) {
    final sorted = [...entries]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(maxEntries).toList();
  }

  Future<void> _deleteFile(String path) async {
    try {
      await File(path).delete();
    } catch (_) {}
  }

  Future<Directory> _directory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/analysis_history_images');
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _metadata() async {
    final directory = await _directory();
    return File('${directory.parent.path}/$_metadataFile');
  }

  Future<List<AnalysisHistoryEntry>> load() async {
    try {
      final file = await _metadata();
      if (!await file.exists()) return [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      final entries = <AnalysisHistoryEntry>[];
      for (final item in decoded) {
        try {
          final entry = AnalysisHistoryEntry.fromJson(Map<String, dynamic>.from(item as Map));
          if (await File(entry.imagePath).exists()) entries.add(entry);
        } catch (_) {
          // Ignore malformed entries so one bad record cannot break History.
        }
      }
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<AnalysisHistoryEntry> entries) async {
    final file = await _metadata();
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<AnalysisHistoryEntry?> saveRemoteResult({
    required String imageUrl,
    required String ruleSetName,
    required List<Map<String, dynamic>> report,
    required double confidenceThreshold,
    required bool showConfidence,
    required bool showBoundingBoxes,
  }) async {
    try {
      final base = await ApiConfig.getBaseUrl();
      final uri = Uri.parse(imageUrl.startsWith('http') ? imageUrl : '$base$imageUrl');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final directory = await _directory();
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final imagePath = '${directory.path}/$id.jpg';
      await File(imagePath).writeAsBytes(response.bodyBytes);
      final entry = AnalysisHistoryEntry(
        id: id,
        timestamp: DateTime.now(),
        ruleSetName: ruleSetName,
        imagePath: imagePath,
        report: report,
        confidenceThreshold: confidenceThreshold,
        showConfidence: showConfidence,
        showBoundingBoxes: showBoundingBoxes,
      );
      final entries = await load();
      entries.insert(0, entry);
      final retained = retainNewest(entries);
      for (final old in entries.where((item) => !retained.contains(item))) {
        await _deleteFile(old.imagePath);
      }
      await _write(retained);
      return entry;
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    final entries = await load();
    final matches = entries.where((e) => e.id == id).toList();
    for (final entry in matches) {
      await _deleteFile(entry.imagePath);
    }
    await _write(entries.where((e) => e.id != id).toList());
  }

  Future<void> clear() async {
    final entries = await load();
    for (final entry in entries) {
      await _deleteFile(entry.imagePath);
    }
    final file = await _metadata();
    if (await file.exists()) await file.delete();
  }
}
