import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

/// About screen — app info, version, features.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.document_scanner, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('v${AppConstants.appVersion}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                )),
            const SizedBox(height: 24),
            Text(
              'A premium all-in-one scanning suite for Android. Scan documents with auto edge detection, '
              'crop & perspective correction, generate QR codes, scan barcodes, and convert images to PDF.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const _FeatureRow(icon: Icons.document_scanner, label: 'Document Scanner'),
            const _FeatureRow(icon: Icons.qr_code_scanner, label: 'QR Scanner'),
            const _FeatureRow(icon: Icons.barcode_reader, label: 'Barcode Scanner'),
            const _FeatureRow(icon: Icons.qr_code_2, label: 'QR Generator'),
            const _FeatureRow(icon: Icons.picture_as_pdf, label: 'Image to PDF'),
            const _FeatureRow(icon: Icons.history, label: 'Scan History'),
            const SizedBox(height: 24),
            Text('Made with Flutter',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                )),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
