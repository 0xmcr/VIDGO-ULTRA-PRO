import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '-';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p) => setState(() => _version = '${p.version}+${p.buildNumber}'));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('VidGo User'),
            subtitle: Text('Premium Experience Enabled'),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: notifier.isDarkMode,
            onChanged: notifier.toggleTheme,
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('https://example.com/privacy'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Terms & Conditions'),
            subtitle: const Text('https://example.com/terms'),
            onTap: () {},
          ),
          ListTile(title: const Text('App Version'), subtitle: Text(_version)),
        ],
      ),
    );
  }
}
