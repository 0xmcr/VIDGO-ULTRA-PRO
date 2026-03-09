import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidgo_ultra_pro/theme_notifier.dart';
import 'package:vidgo_ultra_pro/widgets/premium_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PremiumCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Alex Creator'),
              subtitle: Text('Premium User • Video Enthusiast'),
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            child: SwitchListTile(
              value: theme.isDarkMode,
              onChanged: theme.toggleTheme,
              title: const Text('Dark Mode'),
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  onTap: () => launchUrl(Uri.parse('https://example.com/privacy')),
                ),
                ListTile(
                  title: const Text('Terms & Conditions'),
                  onTap: () => launchUrl(Uri.parse('https://example.com/terms')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(child: ListTile(title: const Text('App Version'), subtitle: Text(_version))),
        ],
      ),
    );
  }
}
