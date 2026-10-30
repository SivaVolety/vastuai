import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/rule_storage.dart';

class RuleSetProvider extends ChangeNotifier {
  List<String> _ruleSetNames = [];
  String? _selected;

  List<String> get ruleSetNames => _ruleSetNames;
  String? get selected => _selected;

  Future<Map<String, List<String>>> get selectedRules async {
    if (_selected == null) return {};
    return await RuleStorage.getRulesForSet(_selected!) ?? {};
  }

  RuleSetProvider() {
    load();
  }

  Future<void> load() async {
    _ruleSetNames = await RuleStorage.getRuleSetNames();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_rule_set');
    _selected = saved != null && _ruleSetNames.contains(saved)
        ? saved
        : (_ruleSetNames.isNotEmpty ? _ruleSetNames.first : null);
    notifyListeners();
  }

  Future<void> select(String name) async {
    _selected = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_rule_set', name);
    notifyListeners();
  }
}
