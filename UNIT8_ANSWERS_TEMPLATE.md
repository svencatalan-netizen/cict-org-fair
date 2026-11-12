# Unit 8 written-answer template

Fill in actual results and URLs after running the build/deployment on your computer. Do not claim a deployment or test passed until you have the evidence.

## A. Prepare the release

**A(a). Version**
The version in `pubspec.yaml` was changed from `1.0.0+1` to `1.1.0+2`. The version name is `1.1.0` and the build number is `2`.

**A(b). VersionTile**
The About screen uses `PackageInfo.fromPlatform()` from `package_info_plus` and displays `Version 1.1.0 (build 2)`. On the web, `package_info_plus` reads the generated `version.json` file.

**A(c). App name**
The web page title, Apple web-app title, web manifest name/short name/description, and Android application label were changed to identify the app as `CICT Org Fair`.

**A(d). Android internet permission**
The main Android manifest includes `android.permission.INTERNET` above the `<application>` element so release builds can access the online CMS.

**A(e). Git status**
Paste or attach your actual `git status` screenshot here. It must show that `cms.json` is not tracked. Also make sure `android/key.properties` and keystore files are ignored.

## B. Deploy to the web

**B(a). `build/web/version.json`**
After the release web build, open `build/web/version.json` and copy its exact contents or values here. It should report the app name, version `1.1.0`, and build number `2`. The About screen's `VersionTile` displays these values through `package_info_plus`.

**B(b). Live URL**
Live website: _paste your actual deployed URL here_.

**B(c). Phone test / CORS**
_Describe what happened when you opened the live URL on your phone. If no issue occurred, state that the What's On events loaded. If a CORS or mixed-content error occurred, state the exact fix you made._

**B(d). Content without a release**
Changing and publishing event content in Contentful changes the data returned by the Content Delivery API. The deployed Flutter code requests the CMS data when the app loads or refreshes, so the new venue or cancellation appears without rebuilding the website. The application code did not change; only CMS content changed.

Attach before-and-after screenshots.

**B(e). CMS address/token in `main.dart.js`**
_Record the actual result of searching the built JavaScript for your CMS endpoint and token._ Values passed using `--dart-define` are compiled into the public web bundle and can be inspected by visitors. This is acceptable only for a read-only Content Delivery token used for public content. A Content Management API token or other write-capable secret must never be embedded in a client app.

## C. CI/CD with GitHub Actions

**C(a). TODO C1**
The deployment workflow runs on pushes to `main` and can also be started manually using `workflow_dispatch`.

**C(b). TODO C2**
The web build uses `--base-href "/${{ github.event.repository.name }}/"` for GitHub Pages and passes CMS configuration through GitHub repository variables. The read-only CMS token is passed from the `CMS_TOKEN` repository secret.

**C(c). Pages configuration**
_Record your actual GitHub Pages settings, Actions run, and deployment URL._

**C(d). CI catches a bug**
_Attach the failing-check screenshot after changing `Cancelled` to `Canceled`, then the passing-check screenshot after restoring the expected text. Record the PR and merge result._

**C(e). Delivery or deployment**
This workflow is continuous deployment because a successful push to `main` automatically publishes the new build. To make it continuous delivery instead, keep the automated build and tests but require a manual approval or release action before the production deployment job can run.

## D. Android release

**D(a). Keystore**
_Record that you created the upload keystore outside the project. Keep the actual passwords and keystore private; do not place them in the public GitHub repository._

**D(b). Signing configuration**
The `android/key.properties` file stores the keystore path, alias, and passwords. The Gradle release signing configuration reads those values. The properties file and keystore are excluded by `.gitignore`.

**D(c). APK test**
_Record the actual successful release build, install test, What's On screenshot, and About screen showing Version 1.1.0 (build 2)._

**D(d). Why the same signing key?**
Android uses the signing certificate to identify the publisher of an installed app. An update must have a compatible signing identity or Android will reject it as an update to the installed app. With Play App Signing, Google keeps the app-signing key, so a lost upload key can be replaced by requesting an upload-key reset in Play Console. Without Play App Signing, losing the signing key can prevent you from publishing updates that Android accepts for the existing app; users may need a separately identified app rather than an in-place update.

## Evidence URLs

1. GitHub repository: _paste your own public repository URL_
2. Deployed web app: _paste your actual GitHub Pages URL_
