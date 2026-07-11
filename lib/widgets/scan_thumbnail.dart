import 'dart:io';
import 'package:flutter/material.dart';

/// Displays a scan thumbnail with a fallback icon when the file is missing.
class ScanThumbnail extends StatelessWidget {
  const ScanThumbnail({
    super.key,
    required this.path,
    this.icon = Icons.description_outlined,
    this.size = 64,
  });

  final String? path;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (path == null || !File(path!).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: size * 0.4),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
