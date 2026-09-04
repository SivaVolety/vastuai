import 'package:flutter/material.dart';
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
    _selected ??= _ruleSetNames.isNotEmpty ? _ruleSetNames.first : null;
    notifyListeners();
  }

  void select(String name) {
    _selected = name;
    notifyListeners();
  }
}
