import 'package:uuid/uuid.dart';

enum ScanType { document, qr, barcode, qrGenerated, imageToPdf }

enum ColorMode { original, colorEnhanced, grayscale, blackWhite }

/// A single saved scan / generated document record.
class ScanDocument {
  ScanDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    required this.pagePaths,
    this.pdfPath,
    this.thumbnailPath,
    this.scannedValue,
    this.colorMode = ColorMode.original,
    this.isFavorite = false,
  });

  final String id;
  final ScanType type;
  String title;
  final DateTime createdAt;
  final List<String> pagePaths;
  String? pdfPath;
  String? thumbnailPath;
  String? scannedValue;
  ColorMode colorMode;
  bool isFavorite;

  factory ScanDocument.create({
    required ScanType type,
    required String title,
    required List<String> pagePaths,
    String? pdfPath,
    String? thumbnailPath,
    String? scannedValue,
    ColorMode colorMode = ColorMode.original,
    bool isFavorite = false,
  }) {
    return ScanDocument(
      id: const Uuid().v4(),
      type: type,
      title: title,
      createdAt: DateTime.now(),
      pagePaths: pagePaths,
      pdfPath: pdfPath,
      thumbnailPath: thumbnailPath,
      scannedValue: scannedValue,
      colorMode: colorMode,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'page_paths': pagePaths.join('|'),
        'pdf_path': pdfPath,
        'thumbnail_path': thumbnailPath,
        'scanned_value': scannedValue,
        'color_mode': colorMode.name,
        'is_favorite': isFavorite ? 1 : 0,
      };

  factory ScanDocument.fromMap(Map<String, dynamic> map) => ScanDocument(
        id: map['id'] as String,
        type: ScanType.values.byName(map['type'] as String),
        title: map['title'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        pagePaths:
            (map['page_paths'] as String).split('|').where((e) => e.isNotEmpty).toList(),
        pdfPath: map['pdf_path'] as String?,
        thumbnailPath: map['thumbnail_path'] as String?,
        scannedValue: map['scanned_value'] as String?,
        colorMode: ColorMode.values.byName(map['color_mode'] as String),
        isFavorite: (map['is_favorite'] as int) == 1,
      );

  ScanDocument copyWith({
    String? title,
    String? pdfPath,
    String? thumbnailPath,
    String? scannedValue,
    ColorMode? colorMode,
    bool? isFavorite,
    List<String>? pagePaths,
  }) =>
      ScanDocument(
        id: id,
        type: type,
        title: title ?? this.title,
        createdAt: createdAt,
        pagePaths: pagePaths ?? this.pagePaths,
        pdfPath: pdfPath ?? this.pdfPath,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
        scannedValue: scannedValue ?? this.scannedValue,
        colorMode: colorMode ?? this.colorMode,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
