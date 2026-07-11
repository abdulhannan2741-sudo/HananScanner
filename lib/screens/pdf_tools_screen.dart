import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../widgets/scan_thumbnail.dart';
import 'pdf_viewer_screen.dart';

/// PDF Tools — lists all PDFs (documents & image-to-pdf) with viewer access.
class PdfToolsScreen extends StatelessWidget {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentsProvider>().docs;
    final pdfs = docs.where((d) => d.pdfPath != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Tools')),
      body: pdfs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No PDFs yet'),
                  const SizedBox(height: 8),
                  Text('Scan documents or convert images to create PDFs',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pdfs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final doc = pdfs[i];
                return ListTile(
                  leading: ScanThumbnail(
                    path: doc.thumbnailPath,
                    icon: Icons.picture_as_pdf,
                    size: 48,
                  ),
                  title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${doc.pagePaths.length} pages • ${_formatDate(doc.createdAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (doc.pdfPath != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            path: doc.pdfPath!,
                            title: doc.title,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
