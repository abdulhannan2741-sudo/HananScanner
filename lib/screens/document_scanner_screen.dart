import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/scan_document.dart';
import '../providers/documents_provider.dart';
import '../services/image_processor.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:provider/provider.dart';

/// Document Scanner: capture / pick images, auto-crop, apply color modes,
/// optionally correct perspective, then save as a multi-page PDF.
class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final List<String> _pages = [];
  ColorMode _colorMode = ColorMode.colorEnhanced;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _colorMode = context.read<DocumentsProvider>().docs.isNotEmpty
        ? ColorMode.colorEnhanced
        : ColorMode.colorEnhanced;
  }

  Future<void> _pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted && mounted) {
      _toast('Camera permission denied');
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    if (file == null) return;
    _addPage(file.path);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 95);
    for (final f in files) {
      _addPage(f.path);
    }
  }

  Future<void> _addPage(String sourcePath) async {
    setState(() => _processing = true);
    try {
      final ip = ImageProcessor.instance;
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      var pagePath = await StorageService.instance.newScanPagePath(docId, _pages.length + 1);

      // Auto-crop
      final cropped = await ip.autoCrop(sourcePath);
      await File(pagePath).writeAsBytes(await File(cropped).readAsBytes());

      // Apply color mode
      final colored = await ip.applyColorMode(pagePath, _colorMode);
      if (colored != pagePath) {
        await File(colored).copy(pagePath);
      }

      setState(() => _pages.add(pagePath));
    } catch (e) {
      if (mounted) _toast('Failed: $e');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _saveAsPdf() async {
    if (_pages.isEmpty) return;
    setState(() => _processing = true);
    try {
      final title = 'Scan ${DateTime.now().toIso8601String().substring(0, 16)}';
      final pdfPath = await StorageService.instance.newPdfPath(title);
      await PdfService.instance.buildPdf(pagePaths: _pages, outPath: pdfPath, title: title);

      final thumb = await ImageProcessor.instance.generateThumbnail(_pages.first);
      final doc = ScanDocument.create(
        type: ScanType.document,
        title: title,
        pagePaths: _pages,
        pdfPath: pdfPath,
        thumbnailPath: thumb,
        colorMode: _colorMode,
      );
      await context.read<DocumentsProvider>().add(doc);

      if (mounted) {
        _toast('Saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _toast('Failed: $e');
    } finally {
      setState(() => _processing = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      body: Column(
        children: [
          // Color mode selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: _ColorModeSelector(
              mode: _colorMode,
              onChanged: (m) => setState(() => _colorMode = m),
            ),
          ),
          Expanded(
            child: _pages.isEmpty
                ? _EmptyState(onCamera: _pickFromCamera, onGallery: _pickFromGallery)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_pages[i]), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton.filledTonal(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _pages.removeAt(i)),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_processing)
            const LinearProgressIndicator(),
          BannerAdWidget(),
        ],
      ),
      floatingActionButton: _pages.isEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan'),
              onPressed: _pickFromCamera,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: _pickFromCamera,
                  child: const Icon(Icons.add_a_photo),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'save',
                  icon: const Icon(Icons.save),
                  label: const Text('Save PDF'),
                  onPressed: _processing ? null : _saveAsPdf,
                ),
              ],
            ),
    );
  }
}

class _ColorModeSelector extends StatelessWidget {
  const _ColorModeSelector({required this.mode, required this.onChanged});
  final ColorMode mode;
  final ValueChanged<ColorMode> onChanged;

  static const _options = [
    (ColorMode.original, 'Original', Icons.image),
    (ColorMode.colorEnhanced, 'Color', Icons.color_lens),
    (ColorMode.grayscale, 'Gray', Icons.grain),
    (ColorMode.blackWhite, 'B&W', Icons.contrast),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (m, label, icon) = _options[i];
          final selected = m == mode;
          return FilterChip(
            selected: selected,
            label: Text(label),
            avatar: Icon(icon, size: 18),
            onSelected: (_) => onChanged(m),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCamera, required this.onGallery});
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_outlined,
                size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Scan your first document',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Auto edge detection, crop & perspective correction',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
