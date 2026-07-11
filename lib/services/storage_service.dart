import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages on-device file storage for scan pages & generated PDFs.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Directory> _scansDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'scans'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<Directory> _pdfsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'pdfs'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<String> newScanPagePath(String docId, int page, {String ext = 'jpg'}) async {
    final dir = await _scansDir();
    final docDir = Directory(p.join(dir.path, docId));
    if (!docDir.existsSync()) docDir.createSync(recursive: true);
    return p.join(docDir.path, 'page_$page.$ext');
  }

  Future<String> newPdfPath(String name) async {
    final dir = await _pdfsDir();
    final safe = name.replaceAll(RegExp(r'[^\w\- ]'), '_');
    return p.join(dir.path, '$safe.pdf');
  }

  Future<void> deleteScanFiles(String docId) async {
    final dir = await _scansDir();
    final docDir = Directory(p.join(dir.path, docId));
    if (docDir.existsSync()) docDir.deleteSync(recursive: true);
  }

  Future<void> deletePdf(String path) async {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }
}
