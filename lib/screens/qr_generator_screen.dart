import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/share_service.dart';
import 'package:provider/provider.dart';

/// QR Code Generator — creates QR codes from text/URLs and saves them.
class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _controller = TextEditingController();
  String _value = '';

  void _generate() {
    setState(() => _value = _controller.text.trim());
  }

  Future<void> _save() async {
    if (_value.isEmpty) return;
    final doc = ScanDocument.create(
      type: ScanType.qrGenerated,
      title: 'QR: ${_value.length > 30 ? '${_value.substring(0, 30)}...' : _value}',
      pagePaths: [],
      scannedValue: _value,
    );
    await context.read<DocumentsProvider>().add(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR saved to My Documents')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter text or URL',
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 24),
            if (_value.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: _value,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _value,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () => ShareService.instance
                                .shareText(_value, subject: 'QR Code'),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ],
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
}
