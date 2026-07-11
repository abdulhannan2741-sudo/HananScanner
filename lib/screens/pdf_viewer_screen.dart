import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../services/share_service.dart';

/// PDF Viewer — renders a local PDF and offers share.
class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ShareService.instance.shareFile(path, subject: title),
          ),
        ],
      ),
      body: SfPdfViewer.file(File(path)),
    );
  }
}
