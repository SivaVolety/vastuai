/// Display vocabulary only. Allowed directions always come from the saved
/// analysis response, never from a current/default rule lookup.
const directionNames = {
  'N': 'North',
  'NE': 'North-East',
  'E': 'East',
  'SE': 'South-East',
  'S': 'South',
  'SW': 'South-West',
  'W': 'West',
  'NW': 'North-West',
};
String directionName(String value) => directionNames[value] ?? value;
String directionList(List<String> codes) {
  final names = codes.map(directionName).toList();
  if (names.length == 1) return names.first;
  if (names.length < 3) return names.join(' or ');
  return '${names.take(names.length - 1).join(', ')}, or ${names.last}';
}

class FindingRemedy {
  const FindingRemedy(
      {required this.headline,
      required this.action,
      required this.basis,
      required this.allowedDirections,
      this.traditionalSignificance});
  final String headline, action, basis;
  final List<String> allowedDirections;
  final String? traditionalSignificance;
  static List<String>? snapshot(Map<String, dynamic> data) {
    final value = data['allowed_directions'];
    if (value is! List) return null;
    return List.unmodifiable(
        value.whereType<String>().where(directionNames.containsKey).toSet());
  }

  static FindingRemedy? fromFinding(Map<String, dynamic> data) {
    if (data['rule_applied'] == false || data['vastu_ok'] == true) return null;
    final codes = snapshot(data) ?? const <String>[];
    final name = (data['label']?.toString() ?? 'item')
        .replaceAll('_', ' ')
        .toLowerCase();
    final directions = directionList(codes);
    return FindingRemedy(
        headline: 'Review $name placement',
        traditionalSignificance: data['traditional_significance'] is String &&
                (data['traditional_significance'] as String).trim().isNotEmpty
            ? data['traditional_significance'] as String
            : null,
        allowedDirections: codes,
        action: codes.isEmpty
            ? 'Review this placement according to the selected rule.'
            : 'Consider repositioning the $name toward $directions if the layout allows.',
        basis: codes.isEmpty
            ? 'No supported allowed directions are recorded for this finding. Review the selected rule.'
            : 'The selected rule allows $directions for this element.');
  }
}
