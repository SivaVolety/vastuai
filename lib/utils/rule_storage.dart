import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const List<Map<String, dynamic>> defaultRuleSets = [
  {
    'name': 'Vastu Presets',
    'rules': {
      'bed': ['S', 'W', 'NW'],
      'dining_table': ['W', 'E', 'S'],
      'kitchen_bar': ['SE', 'NW'],
      'large_sink': ['NW', 'W', 'SE'],
      'sink': ['NW', 'SE'],
      'stairs': ['S', 'W', 'SW'],
    }
  }
];

class RuleStorage {
  static const _key = 'custom_rule_sets';

  static Future<List<Map<String, dynamic>>> getAllRuleSets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final List<Map<String, dynamic>> customSets = jsonStr != null
        ? List<Map<String, dynamic>>.from(json.decode(jsonStr))
        : [];

    return [...defaultRuleSets, ...customSets];
  }

  static Future<Map<String, List<String>>?> getRulesForSet(String name) async {
    final sets = await getAllRuleSets();
    final match = sets.firstWhere((r) => r['name'] == name, orElse: () => {});
    if (match.isEmpty) return null;

    return Map<String, List<String>>.from((match['rules'] as Map).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    ));
  }

  static Future<void> addRuleSet(
      String name, Map<String, List<String>> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final List<Map<String, dynamic>> customSets = jsonStr != null
        ? List<Map<String, dynamic>>.from(json.decode(jsonStr))
        : [];

    customSets.add({'name': name, 'rules': rules});
    await prefs.setString(_key, json.encode(customSets));
  }

  static Future<List<String>> getRuleSetNames() async {
    final sets = await getAllRuleSets();
    return sets.map((r) => r['name'] as String).toList();
  }

  static Future<void> updateRuleSet(
      String name, Map<String, List<String>> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return;

    final List<Map<String, dynamic>> sets =
        List<Map<String, dynamic>>.from(json.decode(jsonStr));
    final index = sets.indexWhere((set) => set['name'] == name);
    if (index != -1) {
      sets[index]['rules'] = rules;
      await prefs.setString(_key, json.encode(sets));
    }
  }

  static Future<void> deleteRuleSet(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return;

    final List<Map<String, dynamic>> sets =
        List<Map<String, dynamic>>.from(json.decode(jsonStr));
    sets.removeWhere((set) => set['name'] == name);
    await prefs.setString(_key, json.encode(sets));
  }
}
