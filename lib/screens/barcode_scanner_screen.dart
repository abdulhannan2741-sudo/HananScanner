import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/share_service.dart';
import 'package:provider/provider.dart';

/// Barcode Scanner — supports all common 1D/2D formats via mobile_scanner.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _captured = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(formats: const [BarcodeFormat.all]);
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
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_captured) return;
              if (capture.barcodes.isNotEmpty) {
                _captured = true;
                _handleResult(capture.barcodes.first);
              }
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point at a barcode',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResult(Barcode barcode) async {
    _controller.stop();
    final value = barcode.rawValue ?? '';
    final format = barcode.format.name;
    final pdfPath = await StorageService.instance.newPdfPath('Barcode_$value');
    await PdfService.instance.buildTextPdf(
      content: 'Format: $format\nValue: $value',
      outPath: pdfPath,
      title: 'Barcode Scan',
    );

    final doc = ScanDocument.create(
      type: ScanType.barcode,
      title: 'Barcode ($format)',
      pagePaths: [],
      pdfPath: pdfPath,
      scannedValue: value,
    );
    await context.read<DocumentsProvider>().add(doc);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Barcode Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Format: $format'),
            const SizedBox(height: 8),
            SelectableText('Value: $value'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () =>
                ShareService.instance.shareFile(pdfPath, subject: 'Barcode Scan'),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
