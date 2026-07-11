import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_constants.dart';

/// Privacy Policy screen with a summary and link to the full policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: July 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
            const SizedBox(height: 16),
            Text('1. Data Storage', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'HananScanner stores all scanned documents, generated QR codes, and PDFs '
              'locally on your device. We do not upload your documents to any server.',
            ),
            const SizedBox(height: 16),
            Text('2. Camera & Storage Permissions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'We require camera access to scan documents and codes, and storage access '
              'to save and retrieve your scans. These permissions are used only when you '
              'actively use the relevant features.',
            ),
            const SizedBox(height: 16),
            Text('3. Advertising', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'This app displays ads via Google AdMob. AdMob may collect device identifiers '
              'to serve relevant ads. See Google\'s privacy policy for details.',
            ),
            const SizedBox(height: 16),
            Text('4. No Personal Data Collected', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'We do not collect, store, or transmit any personally identifiable information. '
              'All data remains on your device unless you explicitly share it.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl)),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View Full Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
