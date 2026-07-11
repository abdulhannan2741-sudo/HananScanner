import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/scan_document.dart';

/// Builds PDF documents from scanned image pages and saves them locally.
class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  /// Build a multi-page PDF from the given image file paths and write it to
  /// [outPath]. Returns the out path.
  Future<String> buildPdf({
    required List<String> pagePaths,
    required String outPath,
    String? title,
  }) async {
    final pdf = pw.Document();

    for (final path in pagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final file = File(outPath);
    await file.writeAsBytes(await pdf.save());
    return outPath;
  }

  /// Build a PDF from a single scanned value (QR/barcode text).
  Future<String> buildTextPdf({
    required String content,
    required String outPath,
    String? title,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title ?? 'Scanned Code',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text(content, style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
    final file = File(outPath);
    await file.writeAsBytes(await pdf.save());
    return outPath;
  }

  /// Human-readable page count label.
  String pageCount(ScanDocument doc) => doc.pagePaths.length == 1
      ? '1 page'
      : '${doc.pagePaths.length} pages';
}
