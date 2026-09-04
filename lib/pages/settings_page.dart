import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rule_set_provider.dart';
import '../utils/rule_storage.dart';
import '../services/api_config.dart';
import '../services/vastu_api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedRuleSet;
  Map<String, List<String>> _rules = {};
  bool _isReadOnly = false;
  final List<String> _items = [
    'bed',
    'dining_table',
    'kitchen_bar',
    'large_sink',
    'sink',
    'stairs'
  ];
  final Map<String, TextEditingController> _controllers = {};
  final _apiController = TextEditingController();
  bool _testingConnection = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RuleSetProvider>(context, listen: false);
    _selectedRuleSet = provider.selected;
    if (_selectedRuleSet != null) {
      _loadRules(_selectedRuleSet!);
    }
    ApiConfig.getBaseUrl().then((url) {
      if (mounted) _apiController.text = url;
    });
  }

  @override
  void dispose() {
    _apiController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    try {
      await ApiConfig.saveBaseUrl(_apiController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backend URL saved.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _testConnection() async {
    setState(() => _testingConnection = true);
    try {
      await VastuApiService().testConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backend connection successful.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  Future<void> _loadRules(String name) async {
    final rules = await RuleStorage.getRulesForSet(name);
    setState(() {
      _selectedRuleSet = name;
      _isReadOnly = name == 'Vastu Presets';
      _rules = rules ?? {};
      _controllers.clear();
      for (var item in _items) {
        final controller = TextEditingController(
          text: (_rules[item] ?? []).join(', '),
        );
        _controllers[item] = controller;
      }
    });
  }

  Future<void> _saveRules() async {
    if (_selectedRuleSet == null || _isReadOnly) return;

    final newRules = <String, List<String>>{};
    for (var item in _items) {
      final text = _controllers[item]?.text ?? '';
      final values =
          text.split(',').map((e) => e.trim().toUpperCase()).where((e) => e.isNotEmpty).toList();
      if (values.isNotEmpty) {
        newRules[item] = values;
      }
    }

    await RuleStorage.updateRuleSet(_selectedRuleSet!, newRules);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rule set saved!')),
      );
      Provider.of<RuleSetProvider>(context, listen: false).load();
    }
  }

  void _addRow() {
    if (_isReadOnly) return;
    setState(() {
      final newItem = 'new_item_${_items.length + 1}';
      _items.add(newItem);
      _controllers[newItem] = TextEditingController();
    });
  }

  void _deleteRow(String item) {
    if (_isReadOnly) return;
    setState(() {
      _items.remove(item);
      _rules.remove(item);
      _controllers.remove(item);
    });
  }

  Future<void> _showCreateRuleSetDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Rule Set'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Rule Set Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                if (Provider.of<RuleSetProvider>(context, listen: false)
                    .ruleSetNames
                    .contains(value.trim())) {
                  return 'A rule set with this name already exists';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final provider = Provider.of<RuleSetProvider>(context, listen: false);
                  final navigator = Navigator.of(context);
                  await RuleStorage.addRuleSet(name, {}); // Create empty set
                  if (mounted) {
                    await provider.load();
                    if (!mounted) return;
                    _loadRules(name);
                    navigator.pop();
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog() async {
    if (_selectedRuleSet == null || _isReadOnly) return;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Rule Set?'),
          content: Text(
              'Are you sure you want to delete "$_selectedRuleSet"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final provider = Provider.of<RuleSetProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                await RuleStorage.deleteRuleSet(_selectedRuleSet!);
                if (mounted) {
                  await provider.load();
                  if (!mounted) return;
                  setState(() {
                    _selectedRuleSet = null;
                    _rules.clear();
                  });
                  navigator.pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RuleSetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rule Sets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create new rule set',
            onPressed: _showCreateRuleSetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'Delete selected rule set',
            onPressed: (_selectedRuleSet == null || _isReadOnly)
                ? null
                : _showDeleteConfirmDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Backend Server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(controller: _apiController, decoration: const InputDecoration(labelText: 'API URL')),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    ElevatedButton(onPressed: _saveApiUrl, child: const Text('Save')),
                    OutlinedButton(onPressed: () async { await ApiConfig.reset(); _apiController.text = ApiConfig.normalize(ApiConfig.defaultBaseUrl); }, child: const Text('Reset to Default')),
                    OutlinedButton(onPressed: _testingConnection ? null : _testConnection, child: _testingConnection ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Test Connection')),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedRuleSet,
              hint: const Text('Select a rule set to edit'),
              items: provider.ruleSetNames
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
              onChanged: (name) {
                if (name != null) {
                  _loadRules(name);
                }
              },
            ),
            const SizedBox(height: 20),
            if (_selectedRuleSet != null)
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Allowed Directions')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _items.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item)),
                            DataCell(
                              TextFormField(
                                controller: _controllers[item],
                                readOnly: _isReadOnly,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., N, NE, S',
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: _isReadOnly ? null : () => _deleteRow(item),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                  onPressed: _isReadOnly ? null : _addRow,
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedRuleSet != null && !_isReadOnly ? _saveRules : null,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
