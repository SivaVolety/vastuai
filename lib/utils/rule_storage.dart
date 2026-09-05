import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> modelLabels = [
  'bed', 'bedroom', 'car', 'closet', 'coffee_table', 'dining_table', 'door',
  'garage', 'kitchen_bar', 'large_sink', 'large_sofa', 'laundry', 'living_room',
  'main_entrance', 'mbr', 'round_table', 'sink', 'small_sink', 'small_sofa',
  'stairs', 'stove', 'tub', 'twin_sink', 'window', 'windows',
];

const List<String> directionOptions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

const Map<String, List<String>> vastuPresetRules = {
  'bed': ['S', 'W', 'NW'], 'dining_table': ['W', 'E', 'S'],
  'kitchen_bar': ['SE', 'NW'], 'large_sink': ['NW', 'W', 'SE'],
  'sink': ['NW', 'SE'], 'stairs': ['S', 'W', 'SW'],
  'garage': ['W', 'S', 'NW'], 'stove': ['SE', 'NW'], 'mbr': ['SW'],
  'bedroom': ['NW', 'W', 'SW'], 'laundry': ['NW', 'W', 'SW'],
  'living_room': ['N', 'NE', 'E'], 'main_entrance': ['N', 'E', 'NE', 'W'],
  'closet': ['W', 'SW', 'NW'], 'car': ['NW', 'W', 'SW'],
};

// Simplified Compass-Bagua heuristic. Furniture without a universal compass
// placement rule is intentionally omitted and therefore not evaluated.
const Map<String, List<String>> fengShuiPresetRules = {
  'sink': ['N'], 'small_sink': ['N'], 'large_sink': ['N'], 'kitchen_bar': ['S'],
};

const List<Map<String, dynamic>> defaultRuleSets = [
  {'name': 'Vastu Presets', 'rules': vastuPresetRules},
  {'name': 'Feng Shui Compass Preset', 'rules': fengShuiPresetRules},
];

class RuleStorage {
  static const _key = 'custom_rule_sets';
  static const builtInNames = ['Vastu Presets', 'Feng Shui Compass Preset'];

  static bool isBuiltIn(String name) => builtInNames.contains(name);

  static Future<List<Map<String, dynamic>>> getAllRuleSets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final customSets = jsonStr == null
        ? <Map<String, dynamic>>[]
        : (json.decode(jsonStr) as List)
            .map((item) => Map<String, dynamic>.from(item as Map)).toList();
    return [...defaultRuleSets, ...customSets];
  }

  static Future<Map<String, List<String>>?> getRulesForSet(String name) async {
    final sets = await getAllRuleSets();
    Map<String, dynamic>? match;
    for (final set in sets) {
      if (set['name'] == name) { match = set; break; }
    }
    if (match == null) return null;
    final rules = Map<String, dynamic>.from(match['rules'] as Map);
    return rules.map((key, value) => MapEntry(
      key, (value as List).map((item) => item.toString().toUpperCase()).toList()));
  }

  static Future<void> addRuleSet(String name, Map<String, List<String>> rules) async {
    if (isBuiltIn(name)) throw ArgumentError('Built-in presets are read-only.');
    final prefs = await SharedPreferences.getInstance();
    final sets = await _customSets(prefs);
    sets.add({'name': name, 'rules': _normalizedRules(rules)});
    await prefs.setString(_key, json.encode(sets));
  }

  static Future<List<String>> getRuleSetNames() async =>
      (await getAllRuleSets()).map((r) => r['name'] as String).toList();

  static Future<void> updateRuleSet(String name, Map<String, List<String>> rules) async {
    if (isBuiltIn(name)) throw ArgumentError('Built-in presets are read-only.');
    final prefs = await SharedPreferences.getInstance();
    final sets = await _customSets(prefs);
    final index = sets.indexWhere((set) => set['name'] == name);
    if (index == -1) throw ArgumentError('Rule set not found.');
    sets[index]['rules'] = _normalizedRules(rules);
    await prefs.setString(_key, json.encode(sets));
  }

  static Future<void> deleteRuleSet(String name) async {
    if (isBuiltIn(name)) throw ArgumentError('Built-in presets are read-only.');
    final prefs = await SharedPreferences.getInstance();
    final sets = await _customSets(prefs);
    sets.removeWhere((set) => set['name'] == name);
    await prefs.setString(_key, json.encode(sets));
  }

  static Future<List<Map<String, dynamic>>> _customSets(SharedPreferences prefs) async {
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    return (json.decode(jsonStr) as List)
        .map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Map<String, List<String>> _normalizedRules(Map<String, List<String>> rules) =>
      rules.map((label, dirs) => MapEntry(label,
          dirs.map((direction) => direction.toUpperCase()).toSet().toList()));
}
