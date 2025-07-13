import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('VastuAI',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _drawerItem(context, Icons.home, 'Home', '/'),
            _drawerItem(context, Icons.tune, 'Advanced', '/advanced'),
            _drawerItem(context, Icons.settings, 'Settings', '/settings'),
            _drawerItem(context, Icons.help_outline, 'Help', '/help'),
            _drawerItem(context, Icons.info_outline, 'About', '/about'),
            const Divider(),
            ListTile(
              title: const Text('Version: 1.0.0'),
              subtitle: const Text('Release Notes'),
              onTap: () => Navigator.pushNamed(context, '/releases'),
            ),
          ],
        ),
      ),
      body: body,
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context); // close drawer
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        });
  }
}
