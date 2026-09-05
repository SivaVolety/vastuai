class AnalysisHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String ruleSetName;
  final String imagePath;
  final List<Map<String, dynamic>> report;
  final double confidenceThreshold;
  final bool showConfidence;
  final bool showBoundingBoxes;
  final String orientation;

  const AnalysisHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.ruleSetName,
    required this.imagePath,
    required this.report,
    this.confidenceThreshold = 0.25,
    this.showConfidence = false,
    this.showBoundingBoxes = true,
    this.orientation = 'N',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'ruleSetName': ruleSetName,
        'imagePath': imagePath,
        'report': report,
        'confidenceThreshold': confidenceThreshold,
        'showConfidence': showConfidence,
        'showBoundingBoxes': showBoundingBoxes,
        'orientation': orientation,
      };

  factory AnalysisHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawReport = json['report'];
    return AnalysisHistoryEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ruleSetName: json['ruleSetName'] as String? ?? 'Vastu Presets',
      imagePath: json['imagePath'] as String,
      report: rawReport is List
          ? rawReport.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : const [],
      confidenceThreshold: (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.25,
      showConfidence: json['showConfidence'] as bool? ?? false,
      showBoundingBoxes: json['showBoundingBoxes'] as bool? ?? true,
      orientation: json['orientation'] as String? ?? 'N',
    );
  }

  // A missing rule_applied field is legacy data and remains evaluated. An
  // explicit false means the active rule set did not cover this label.
  Iterable<Map<String, dynamic>> get _evaluatedReport =>
      report.where((item) => item['rule_applied'] != false);

  int get passedCount => _evaluatedReport.where((item) => item['vastu_ok'] == true).length;
  int get failedCount => _evaluatedReport.where((item) => item['vastu_ok'] == false).length;
}
