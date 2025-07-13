import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/advanced_page.dart';
import 'pages/settings_page.dart';
import 'pages/help_page.dart';
import 'pages/about_page.dart';
import 'pages/release_notes_page.dart';
import 'widgets/app_scaffold.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VastuAI',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const AppScaffold(title: 'Home', body: HomePage()),
        '/advanced': (_) =>
            const AppScaffold(title: 'Advanced', body: AdvancedPage()),
        '/settings': (_) =>
            const AppScaffold(title: 'Settings', body: SettingsPage()),
        '/help': (_) => const AppScaffold(title: 'Help', body: HelpPage()),
        '/about': (_) => const AppScaffold(title: 'About', body: AboutPage()),
        '/releases': (_) =>
            const AppScaffold(title: 'Release Notes', body: ReleaseNotesPage()),
      },
    );
  }
}
