# Debug Keystore

This directory should contain `debug.keystore` for fallback release signing
when `android/key.properties` is not present.

The standard Flutter debug keystore is used automatically by the Flutter tooling
during `flutter build`. If you need to generate one manually:

```bash
keytool -genkey -v -keystore android/app/debug.keystore \
  -storepass android -alias androiddebugkey -keypass android \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Android,C=US"
```

For production releases, create a proper release keystore and configure
`android/key.properties` (see README.md).
