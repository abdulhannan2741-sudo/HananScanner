import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/share_service.dart';
import 'package:provider/provider.dart';

/// QR Code Scanner using mobile_scanner.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _controller;
  bool _captured = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ensurePermission() async {
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    _ensurePermission();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_captured) return;
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _captured = true;
                _handleResult(barcodes.first.rawValue ?? '');
              }
            },
          ),
          // Scan overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point at a QR code',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResult(String value) async {
    _controller.stop();
    final pdfPath = await StorageService.instance.newPdfPath('QR_$value');
    await PdfService.instance.buildTextPdf(content: value, outPath: pdfPath, title: 'QR Code');

    final doc = ScanDocument.create(
      type: ScanType.qr,
      title: 'QR: ${value.length > 30 ? '${value.substring(0, 30)}...' : value}',
      pagePaths: [],
      pdfPath: pdfPath,
      scannedValue: value,
    );
    await context.read<DocumentsProvider>().add(doc);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: SelectableText(value),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () {
              ShareService.instance.shareFile(pdfPath, subject: 'QR Scan');
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
