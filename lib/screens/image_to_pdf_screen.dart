import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import 'package:provider/provider.dart';

/// Image to PDF: pick multiple images, reorder, and combine into a PDF.
class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<String> _images = [];
  bool _processing = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 95);
    setState(() => _images.addAll(files.map((f) => f.path)));
  }

  void _removeAt(int i) => setState(() => _images.removeAt(i));

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  Future<void> _buildPdf() async {
    if (_images.isEmpty) return;
    setState(() => _processing = true);
    try {
      final title = 'Images ${DateTime.now().toIso8601String().substring(0, 16)}';
      final pdfPath = await StorageService.instance.newPdfPath(title);
      await PdfService.instance.buildPdf(
        pagePaths: _images,
        outPath: pdfPath,
        title: title,
      );

      final doc = ScanDocument.create(
        type: ScanType.imageToPdf,
        title: title,
        pagePaths: _images,
        pdfPath: pdfPath,
      );
      await context.read<DocumentsProvider>().add(doc);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF created'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => ShareService.instance.shareFile(pdfPath),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image to PDF')),
      body: _images.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No images selected'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Select Images'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _images.length,
                    onReorder: _reorder,
                    itemBuilder: (_, i) => Card(
                      key: ValueKey(_images[i]),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_images[i]),
                              width: 56, height: 56, fit: BoxFit.cover),
                        ),
                        title: Text('Page ${i + 1}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_indicator),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeAt(i),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_processing) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _processing ? null : _buildPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Create PDF'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
