# CICT Org Fair

**Live website:** _Add your deployed GitHub Pages URL after the first successful deployment._

This is the recovered Unit 7 CICT Org Fair Flutter project, prepared for the Unit 8 release, web deployment, GitHub Actions, and Android release assignment.

## Project recovery

The recovered Unit 7 archive supplied the completed `lib/` and `test/` source folders. Platform scaffolding (`web/` and `android/`) was not part of that archive, so generate those folders with your installed Flutter SDK:

```powershell
flutter create --platforms=web,android .
flutter pub get
```

Then apply the Unit 8 web/app-name and Android permission changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\finish-unit8-platforms.ps1
```

Inspect the generated files after running the script.

## Local Contentful setup

Copy the example configuration and fill it with your own Contentful Space ID and read-only Content Delivery API token:

```powershell
Copy-Item .\cms.example.json .\cms.json
```

Example shape (do not use these placeholders as values):

```json
{
  "CMS": "contentful",
  "CMS_SPACE": "YOUR_CONTENTFUL_SPACE_ID",
  "CMS_TOKEN": "YOUR_CONTENT_DELIVERY_API_TOKEN"
}
```

Run locally:

```powershell
flutter run --dart-define-from-file=cms.json
```

`cms.json` is ignored by Git. Never commit `cms.json`, a Content Management API token, `android/key.properties`, or a keystore.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=cms.json
```

The web build produces `build/web/version.json`; the About screen's `VersionTile` reads the version using `package_info_plus`.

## GitHub Pages deployment

Create a **separate public GitHub repository that you own**, for example `org-fair`. This is separate from the class activities repository. Commit the project, including the generated `web/` and `android/` folders, but exclude secrets and build output.

In the new repository, configure:

- Settings → Pages → Build and deployment → Source: **GitHub Actions**.
- Settings → Secrets and variables → Actions → Variables:
  - `CMS` = `contentful`
  - `CMS_SPACE` = your Contentful Space ID
- Settings → Secrets and variables → Actions → Secrets:
  - `CMS_TOKEN` = your read-only Content Delivery API token

The `.github/workflows/deploy.yml` workflow builds with the repository-specific base href and deploys on pushes to `main` (and can be started manually from Actions). After a successful run, copy the deployment URL into the top of this README.

## Android release

Create the upload keystore **outside** the project folder:

```powershell
keytool -genkey -v -keystore "$env:USERPROFILE\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties` (this file is ignored by Git) with your values:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/YOUR_WINDOWS_USER/upload-keystore.jks
```

Then run the helper script to add the release-signing configuration to `android/app/build.gradle.kts`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\enable-android-signing.ps1
```

Inspect the generated Gradle file after the script. The full reference snippet is in `docs/android-signing-kts-snippet.txt`.

Build the APK:

```powershell
flutter build apk --release --dart-define-from-file=cms.json
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

Keep the keystore and its passwords backed up securely. Never commit them.
