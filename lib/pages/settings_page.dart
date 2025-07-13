import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('General Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(title: Text('Option A')),
        ListTile(title: Text('Option B')),
        Divider(),
        Text('Custom Rules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(title: Text('Define Rule 1')),
        ListTile(title: Text('Define Rule 2')),
      ],
    );
  }
}
