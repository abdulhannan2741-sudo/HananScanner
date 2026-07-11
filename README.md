# HananScanner

A premium all-in-one document, QR & barcode scanning suite for Android, built with Flutter and Material 3.

## Features

- **Document Scanner** — auto edge detection, auto crop, perspective correction, HD scan, color/B&W/grayscale modes
- **QR Code Scanner** — scan any QR code
- **Barcode Scanner** — supports all common 1D/2D formats
- **QR Code Generator** — create QR codes from text or URLs
- **Image to PDF** — combine multiple images into a multi-page PDF
- **PDF Tools** — view, share, and manage all generated PDFs
- **My Documents** — scan history with search, favorites, and type filters
- **Settings** — dark mode, default color mode, HD scan, auto-crop, ads toggle
- **About & Privacy Policy**
- **Google AdMob** integration (test ad IDs pre-configured)

## Getting Started

### Prerequisites

- Flutter SDK >= 3.19.0 (Dart >= 3.3.0)
- Android SDK (compileSdk 34, minSdk 21)
- Java 17

### Install Dependencies

```bash
flutter pub get
```

### Run in Debug

```bash
flutter run
```

### Generate a Release Keystore

Before publishing, create a release keystore:

```bash
keytool -genkey -v -keystore android/app/release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=release
storeFile=release.keystore
```

The build script automatically picks up `key.properties` if present. Without it, release builds fall back to the debug keystore (for testing only).

### Build Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

The AAB will be at `build/app/outputs/bundle/release/app-release.aab`.

### Build APK (for testing)

```bash
flutter build apk --release
```

## AdMob Configuration

Test ad IDs are pre-configured in:
- `lib/utils/ad_config.dart` — ad unit IDs
- `android/app/src/main/AndroidManifest.xml` — app ID

**Before publishing to Google Play, replace all test IDs with your real AdMob IDs:**

| Type          | Test Ad Unit ID                          |
|---------------|------------------------------------------|
| App Open      | ca-app-pub-3940256099942544/9257395921   |
| Banner        | ca-app-pub-3940256099942544/6300978111   |
| Interstitial  | ca-app-pub-3940256099942544/1033173712   |
| Rewarded      | ca-app-pub-3940256099942544/5224354917   |
| Native        | ca-app-pub-3940256099942544/2247696110   |
| App ID        | ca-app-pub-3940256099942544~3347511713   |

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── scan_document.dart       # Scan document model
├── providers/
│   ├── settings_provider.dart   # Theme & settings state
│   └── documents_provider.dart  # Documents list state
├── services/
│   ├── database_service.dart    # SQLite persistence
│   ├── storage_service.dart     # File storage management
│   ├── image_processor.dart     # Edge detection, crop, color modes
│   ├── pdf_service.dart         # PDF generation
│   ├── share_service.dart       # Sharing files/text
│   └── ad_service.dart          # AdMob wrapper
├── screens/
│   ├── home_screen.dart         # Dashboard with feature cards
│   ├── document_scanner_screen.dart
│   ├── qr_scanner_screen.dart
│   ├── barcode_scanner_screen.dart
│   ├── qr_generator_screen.dart
│   ├── image_to_pdf_screen.dart
│   ├── pdf_tools_screen.dart
│   ├── pdf_viewer_screen.dart
│   ├── my_documents_screen.dart
│   ├── settings_screen.dart
│   ├── about_screen.dart
│   └── privacy_policy_screen.dart
├── utils/
│   ├── app_theme.dart           # Material 3 theme
│   ├── app_constants.dart       # App-wide constants
│   └── ad_config.dart           # AdMob ad unit IDs
└── widgets/
    ├── feature_card.dart        # Premium home screen card
    ├── banner_ad_widget.dart    # AdMob banner
    ├── scan_thumbnail.dart      # Document thumbnail
    └── section_header.dart       # List section header
```

## Tech Stack

- **Flutter** + **Material 3** — UI framework
- **Provider** — state management
- **sqflite** — local database for scan history
- **image** — image processing (edge detection, crop, color modes)
- **mobile_scanner** — QR & barcode scanning
- **qr_flutter** — QR code generation
- **pdf + syncfusion_flutter_pdfviewer** — PDF creation & viewing
- **google_mobile_ads** — AdMob advertising
- **share_plus** — file & text sharing

## License

All rights reserved.
