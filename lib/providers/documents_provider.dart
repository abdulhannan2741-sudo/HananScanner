import 'package:flutter/foundation.dart';
import '../models/scan_document.dart';
import '../services/database_service.dart';

/// Holds the in-memory list of saved scans and exposes CRUD + search.
class DocumentsProvider extends ChangeNotifier {
  DocumentsProvider();

  List<ScanDocument> _docs = [];
  List<ScanDocument> get docs => List.unmodifiable(_docs);

  bool _loading = true;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _docs = await DatabaseService.instance.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(ScanDocument doc) async {
    await DatabaseService.instance.insert(doc);
    _docs.insert(0, doc);
    notifyListeners();
  }

  Future<void> update(ScanDocument doc) async {
    await DatabaseService.instance.update(doc);
    final i = _docs.indexWhere((d) => d.id == doc.id);
    if (i >= 0) _docs[i] = doc;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await DatabaseService.instance.delete(id);
    _docs.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(ScanDocument doc) async {
    doc.isFavorite = !doc.isFavorite;
    await DatabaseService.instance.update(doc);
    notifyListeners();
  }

  List<ScanDocument> favorites() => _docs.where((d) => d.isFavorite).toList();

  List<ScanDocument> byType(ScanType type) =>
      _docs.where((d) => d.type == type).toList();
}
