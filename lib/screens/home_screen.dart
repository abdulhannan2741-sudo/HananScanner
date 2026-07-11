import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/feature_card.dart';
import 'about_screen.dart';
import 'barcode_scanner_screen.dart';
import 'document_scanner_screen.dart';
import 'image_to_pdf_screen.dart';
import 'my_documents_screen.dart';
import 'pdf_tools_screen.dart';
import 'qr_generator_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';

/// Home dashboard — the main entry point showing all premium feature cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(theme: theme)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate([
                  FeatureCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'Document Scanner',
                    subtitle: 'Auto edge & crop',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const DocumentScannerScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.qr_code_scanner,
                    title: 'QR Scanner',
                    subtitle: 'Scan QR codes',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const QrScannerScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.barcode_reader,
                    title: 'Barcode Scanner',
                    subtitle: 'All formats',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const BarcodeScannerScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.qr_code_2,
                    title: 'QR Generator',
                    subtitle: 'Create QR codes',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const QrGeneratorScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.image_to_pdf,
                    title: 'Image to PDF',
                    subtitle: 'Multi-page PDF',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const ImageToPdfScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'PDF Tools',
                    subtitle: 'View & manage',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const PdfToolsScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.folder_open_outlined,
                    title: 'My Documents',
                    subtitle: 'History & favorites',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF455A64), Color(0xFF78909C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const MyDocumentsScreen()),
                  ),
                  FeatureCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Customize app',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF37474F), Color(0xFF607D8B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: BannerAdWidget(enabled: settings.showAds),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      '${AppConstants.appName} v${AppConstants.appVersion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _push(context, const AboutScreen()),
                      child: const Text('About'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.document_scanner, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      AppConstants.appTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
