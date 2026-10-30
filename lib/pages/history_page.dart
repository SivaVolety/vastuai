import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/analysis_history_entry.dart';
import '../services/analysis_history_service.dart';
import 'result_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _service = AnalysisHistoryService();
  List<AnalysisHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _service.load();
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _delete(AnalysisHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete analysis?'),
        content: const Text('This saved analysis will be removed from the device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.delete(entry.id);
      await _reload();
    }
  }

  Future<void> _clear() async {
    if (_entries.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('All saved analyses and their local images will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clear();
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Saved History is available in the mobile app. Web analyses '
            'are not saved; review results before leaving the page.',
            textAlign: TextAlign.center),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [IconButton(onPressed: _entries.isEmpty ? null : _clear, icon: const Icon(Icons.delete_sweep), tooltip: 'Clear History')],
      ),
      body: _entries.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.history, size: 64, color: Colors.grey), SizedBox(height: 12), Text('No analyses yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 6), Text('Your completed floor-plan analyses will appear here.', textAlign: TextAlign.center)])))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: SizedBox(width: 72, height: 72, child: Image.file(File(entry.imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                    title: Text(entry.ruleSetName),
                    subtitle: Text('${entry.timestamp.toLocal()}\n${entry.passedCount} passed • ${entry.failedCount} failed'),
                    isThreeLine: true,
                    trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(entry)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(imageUrl: '', localImagePath: entry.imagePath, vastuReport: entry.report, ruleSetName: entry.ruleSetName, showConfidence: entry.showConfidence, modelVersion: entry.modelVersion))),
                  ),
                );
              },
            ),
    );
  }
}
