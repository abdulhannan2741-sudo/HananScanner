import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_constants.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

/// Settings — theme, default color mode, HD scan, auto-crop, ads, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _Section(theme: theme, title: 'Appearance', children: [
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Theme'),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (v) => settings.setThemeMode(v ?? ThemeMode.system),
              ),
            ),
          ]),
          _Section(theme: theme, title: 'Scanning', children: [
            SwitchListTile(
              secondary: const Icon(Icons.hd_outlined),
              title: const Text('HD Scan'),
              subtitle: const Text('Higher quality output'),
              value: settings.hdScan,
              onChanged: settings.setHdScan,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.crop_free),
              title: const Text('Auto Crop'),
              subtitle: const Text('Auto edge detection & crop'),
              value: settings.autoCrop,
              onChanged: settings.setAutoCrop,
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Default Color Mode'),
              trailing: DropdownButton<ColorMode>(
                value: settings.defaultColorMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: ColorMode.original, child: Text('Original')),
                  DropdownMenuItem(value: ColorMode.colorEnhanced, child: Text('Color')),
                  DropdownMenuItem(value: ColorMode.grayscale, child: Text('Grayscale')),
                  DropdownMenuItem(value: ColorMode.blackWhite, child: Text('B&W')),
                ],
                onChanged: (v) =>
                    settings.setDefaultColorMode(v ?? ColorMode.colorEnhanced),
              ),
            ),
          ]),
          _Section(theme: theme, title: 'Ads', children: [
            SwitchListTile(
              secondary: const Icon(Icons.ads_click),
              title: const Text('Show Ads'),
              subtitle: const Text('Display AdMob banners'),
              value: settings.showAds,
              onChanged: settings.setShowAds,
            ),
          ]),
          _Section(theme: theme, title: 'About', children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('Version'),
              trailing: Text(AppConstants.appVersion),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.title,
    required this.children,
  });
  final ThemeData theme;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
