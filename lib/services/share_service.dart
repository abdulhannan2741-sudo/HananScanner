import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Share / open files externally.
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  Future<void> shareFile(String path, {String? subject}) async {
    final file = File(path);
    if (!file.existsSync()) return;
    await Share.shareXFiles([XFile(path)], subject: subject ?? 'HananScanner');
  }

  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject ?? 'HananScanner');
  }
}
