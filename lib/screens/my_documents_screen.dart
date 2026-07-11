import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';
import '../widgets/scan_thumbnail.dart';
import 'pdf_viewer_screen.dart';

/// My Documents — search, filter by type, favorites, and history list.
class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  String _query = '';
  ScanType? _filter;
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentsProvider>();
    var docs = provider.docs;

    if (_favoritesOnly) docs = docs.where((d) => d.isFavorite).toList();
    if (_filter != null) docs = docs.where((d) => d.type == _filter).toList();
    if (_query.isNotEmpty) {
      docs = docs
          .where((d) =>
              d.title.toLowerCase().contains(_query.toLowerCase()) ||
              (d.scannedValue ?? '').toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Documents')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search documents...',
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
              ),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Favorites'),
                  selected: _favoritesOnly,
                  avatar: const Icon(Icons.star, size: 18),
                  onSelected: (_) => setState(() => _favoritesOnly = !_favoritesOnly),
                ),
                const SizedBox(width: 8),
                ...ScanType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_typeLabel(t)),
                        selected: _filter == t,
                        onSelected: (_) =>
                            setState(() => _filter = _filter == t ? null : t),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text('No documents found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _DocTile(doc: docs[i]),
                  ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(ScanType t) => switch (t) {
        ScanType.document => 'Documents',
        ScanType.qr => 'QR',
        ScanType.barcode => 'Barcode',
        ScanType.qrGenerated => 'QR Gen',
        ScanType.imageToPdf => 'Img→PDF',
      };
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.doc});
  final ScanDocument doc;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DocumentsProvider>();
    return ListTile(
      leading: ScanThumbnail(
        path: doc.thumbnailPath,
        icon: _iconFor(doc.type),
        size: 48,
      ),
      title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${_typeLabel(doc.type)} • ${_formatDate(doc.createdAt)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              doc.isFavorite ? Icons.star : Icons.star_border,
              color: doc.isFavorite ? Colors.amber : null,
            ),
            onPressed: () => provider.toggleFavorite(doc),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'view' && doc.pdfPath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PdfViewerScreen(path: doc.pdfPath!, title: doc.title),
                  ),
                );
              } else if (v == 'share' && doc.pdfPath != null) {
                ShareService.instance.shareFile(doc.pdfPath!, subject: doc.title);
              } else if (v == 'delete') {
                await StorageService.instance.deleteScanFiles(doc.id);
                if (doc.pdfPath != null) {
                  await StorageService.instance.deletePdf(doc.pdfPath!);
                }
                await provider.remove(doc.id);
              }
            },
            itemBuilder: (_) => [
              if (doc.pdfPath != null)
                const PopupMenuItem(value: 'view', child: Text('View PDF')),
              if (doc.pdfPath != null)
                const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      onTap: () {
        if (doc.scannedValue != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(doc.title),
              content: SelectableText(doc.scannedValue!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else if (doc.pdfPath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(path: doc.pdfPath!, title: doc.title),
            ),
          );
        }
      },
    );
  }

  String _typeLabel(ScanType t) => switch (t) {
        ScanType.document => 'Document',
        ScanType.qr => 'QR',
        ScanType.barcode => 'Barcode',
        ScanType.qrGenerated => 'QR Gen',
        ScanType.imageToPdf => 'Image→PDF',
      };

  IconData _iconFor(ScanType t) => switch (t) {
        ScanType.document => Icons.description,
        ScanType.qr => Icons.qr_code,
        ScanType.barcode => Icons.barcode_reader,
        ScanType.qrGenerated => Icons.qr_code_2,
        ScanType.imageToPdf => Icons.image_to_pdf,
      };

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
