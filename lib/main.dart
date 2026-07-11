import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/documents_provider.dart';
import 'providers/settings_provider.dart';
import 'services/ad_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdService.instance.initialize();
  runApp(const HananScannerApp());
}

class HananScannerApp extends StatelessWidget {
  const HananScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'HananScanner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
