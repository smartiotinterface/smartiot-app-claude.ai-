# ============================================================================
# build_release.ps1 — SmartIoT v1.0.4 Release Build Script (Windows PowerShell)
# Developer: Sobuj Billah / Smart IoT Interface
#
# ব্যবহার: PowerShell-এ প্রজেক্ট ফোল্ডারে গিয়ে চালান →  .\build_release.ps1
# ============================================================================

Write-Host "============================================================"
Write-Host " SmartIoT v1.0.4 — Release Build Script"
Write-Host " Developer: Sobuj Billah / Smart IoT Interface"
Write-Host "============================================================"
Write-Host ""

Write-Host "[1/6] Cleaning previous builds..."
flutter clean

Write-Host "[2/6] Getting dependencies..."
flutter pub get

Write-Host "[3/6] Static analysis (fail fast before wasting build time)..."
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ flutter analyze failed — fix the errors above before building." -ForegroundColor Red
    exit 1
}

Write-Host "[4/6] Running tests..."
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ flutter test failed — fix the failing tests above before building." -ForegroundColor Red
    exit 1
}

Write-Host "[5/6] Building Release APK..."
flutter build apk --release --split-per-abi

Write-Host "[6/6] Building Release AAB (Play Store)..."
flutter build appbundle --release

Write-Host "============================================================"
Write-Host " BUILD COMPLETE!"
Write-Host " APK (WhatsApp/sideload): build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
Write-Host " AAB (Play Store):        build\bundle\release\app-release.aab"
Write-Host "============================================================"
Write-Host ""
Write-Host "IMPORTANT: lib\firebase_options.dart-এর উপরের কমেন্টে Release SHA-1/SHA-256 আছে"
Write-Host "Firebase Console -> Project Settings -> Android App-এ যোগ করুন (Google Sign-In কাজ করার জন্য)"
Write-Host ""
Write-Host "চালানোর আগে নিশ্চিত করুন:"
Write-Host "  [ ] android\key.properties -- real keystore password আছে (CREATE_KEYSTORE.md দেখুন)"
Write-Host "  [ ] esp32\SmartIoT_firmware\secrets.h -- FIREBASE_DB_SECRET real value দেওয়া আছে"
Write-Host "  [ ] Firebase Console -> Realtime Database -> Rules deploy করা হয়েছে"
