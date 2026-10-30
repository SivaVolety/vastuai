import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rule_set_provider.dart';
import '../utils/rule_storage.dart';
import '../services/api_config.dart';
import '../services/vastu_api_service.dart';

String _labelTitle(String label) => label.split('_').map((part) =>
    part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}').join(' ');

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedRuleSet;
  Map<String, List<String>> _rules = {};
  bool _isReadOnly = false;
  final _apiController = TextEditingController();
  bool _testingConnection = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RuleSetProvider>(context, listen: false);
    _selectedRuleSet = provider.selected;
    if (_selectedRuleSet != null) _loadRules(_selectedRuleSet!);
    ApiConfig.getBaseUrl().then((url) {
      if (mounted) _apiController.text = url;
    });
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  Future<void> _loadRules(String name) async {
    final rules = await RuleStorage.getRulesForSet(name) ?? {};
    if (!mounted) return;
    await Provider.of<RuleSetProvider>(context, listen: false).select(name);
    setState(() {
      _selectedRuleSet = name;
      _isReadOnly = RuleStorage.isBuiltIn(name);
      _rules = {for (final entry in rules.entries) entry.key: [...entry.value]};
    });
  }

  Future<void> _saveApiUrl() async {
    try {
      await ApiConfig.saveBaseUrl(_apiController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend URL saved.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _testConnection() async {
    setState(() => _testingConnection = true);
    try {
      await VastuApiService().testConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend connection successful.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  Future<void> _showCreateRuleSetDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Create New Rule Set', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Rule Set Name'),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Name cannot be empty';
                  if (Provider.of<RuleSetProvider>(context, listen: false).ruleSetNames.contains(name)) {
                    return 'A rule set with this name already exists';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await RuleStorage.addRuleSet(controller.text.trim(), {});
                    if (!mounted) return;
                    final provider = Provider.of<RuleSetProvider>(context, listen: false);
                    await provider.load();
                    if (!mounted || !sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    await _loadRules(controller.text.trim());
                  },
                  child: const Text('Create'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _saveRules() async {
    if (_selectedRuleSet == null || _isReadOnly) return;
    if (_rules.isEmpty || _rules.values.any((directions) => directions.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one rule with a direction before saving.')),
      );
      return;
    }
    await RuleStorage.updateRuleSet(_selectedRuleSet!, _rules);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rule set saved.')));
      await Provider.of<RuleSetProvider>(context, listen: false).load();
    }
  }

  void _addRow() {
    if (_isReadOnly) return;
    final available = modelLabels.where((label) => !_rules.containsKey(label)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All supported labels are already included.')));
      return;
    }
    setState(() => _rules[available.first] = []);
  }

  void _deleteRow(String label) {
    if (_isReadOnly) return;
    setState(() => _rules.remove(label));
  }

  Future<void> _showDeleteConfirmDialog() async {
    if (_selectedRuleSet == null || _isReadOnly) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Rule Set?'),
        content: Text('Are you sure you want to delete "$_selectedRuleSet"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = Provider.of<RuleSetProvider>(context, listen: false);
    await RuleStorage.deleteRuleSet(_selectedRuleSet!);
    await provider.load();
    if (!mounted) return;
    setState(() {
      _selectedRuleSet = provider.selected;
      _isReadOnly = _selectedRuleSet == null || RuleStorage.isBuiltIn(_selectedRuleSet!);
      _rules = {};
    });
    if (_selectedRuleSet != null) await _loadRules(_selectedRuleSet!);
  }

  Widget _ruleEditorRow(String label, List<String> directions) {
    final isLast = label == _rules.keys.last;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: label,
                decoration: const InputDecoration(labelText: 'Detected object'),
                items: modelLabels.map((item) => DropdownMenuItem(value: item, child: Text(_labelTitle(item)))).toList(),
                onChanged: _isReadOnly ? null : (newLabel) {
                  if (newLabel == null || newLabel == label || _rules.containsKey(newLabel)) return;
                  setState(() {
                    final old = _rules.remove(label) ?? [];
                    _rules[newLabel] = old;
                  });
                },
              ),
            ),
            IconButton(
              tooltip: 'Remove rule',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _isReadOnly ? null : () => _deleteRow(label),
            ),
          ]),
          const SizedBox(height: 8),
          const Text('Allowed directions', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: directionOptions.map((direction) {
              final selected = directions.contains(direction);
              return FilterChip(
                label: Text(direction),
                selected: selected,
                onSelected: _isReadOnly ? null : (value) => setState(() {
                  final next = {...directions};
                  value ? next.add(direction) : next.remove(direction);
                  _rules[label] = directionOptions.where(next.contains).toList();
                }),
              );
            }).toList(),
          ),
          if (!_isReadOnly && directions.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 4), child: Text('Select at least one direction.', style: TextStyle(color: Colors.red))),
          if (!_isReadOnly && isLast) const SizedBox.shrink(),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RuleSetProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rule Sets'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Create rule set', onPressed: _showCreateRuleSetDialog),
          IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent), tooltip: 'Delete rule set', onPressed: (_selectedRuleSet == null || _isReadOnly) ? null : _showDeleteConfirmDialog),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Backend Server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _apiController, decoration: const InputDecoration(labelText: 'API URL')),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ElevatedButton(onPressed: _saveApiUrl, child: const Text('Save')),
                OutlinedButton(onPressed: () async { await ApiConfig.reset(); if (mounted) setState(() => _apiController.text = ApiConfig.normalize(ApiConfig.defaultBaseUrl)); }, child: const Text('Reset to Default')),
                OutlinedButton(onPressed: _testingConnection ? null : _testConnection, child: _testingConnection ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Test Connection')),
              ]),
            ]))),
            const SizedBox(height: 16),
            const Text('Rule Sets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedRuleSet,
              hint: const Text('Select a rule set'),
              items: provider.ruleSetNames.map((name) => DropdownMenuItem(value: name, child: Row(children: [if (RuleStorage.isBuiltIn(name)) const Icon(Icons.lock_outline, size: 16), const SizedBox(width: 6), Text(name)]))).toList(),
              onChanged: (name) { if (name != null) _loadRules(name); },
            ),
            if (_selectedRuleSet == 'Feng Shui Compass Preset')
              const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Simplified Compass-Bagua heuristic: water fixtures use North and cooking uses South. Other furniture is not evaluated by this preset.', style: TextStyle(fontStyle: FontStyle.italic))),
            if (_selectedRuleSet == 'Vastu Presets')
              const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Built-in Vastu directional rules. This preset is read-only.', style: TextStyle(fontStyle: FontStyle.italic))),
            if (_selectedRuleSet != null) ...[
              ..._rules.entries.map((entry) => _ruleEditorRow(entry.key, entry.value)),
              if (!_isReadOnly) OutlinedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text('Add object rule')),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _isReadOnly ? null : _saveRules, child: const Text('Save Changes'))),
            ],
          ]),
        ),
      ),
    );
  }
}
