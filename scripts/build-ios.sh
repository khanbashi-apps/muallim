#!/usr/bin/env bash
set -euo pipefail
XC=$(ls -d /Applications/Xcode_26*.app 2>/dev/null | sort -V | tail -1 || true)
if [ -n "$XC" ]; then sudo xcode-select -s "$XC/Contents/Developer"; fi
echo "== أدوات" ; node -v ; xcodebuild -version
npm install --no-audit --no-fund
bash scripts/prepare-www.sh
npx cap add ios
P=ios/App/App/Info.plist
pb() { /usr/libexec/PlistBuddy -c "Delete :$1" "$P" 2>/dev/null || true; /usr/libexec/PlistBuddy -c "Add :$1 string $2" "$P"; }
pb NSCameraUsageDescription "يحتاج التطبيق الكاميرا لتصوير ورقة الواجب"
pb NSPhotoLibraryUsageDescription "يحتاج التطبيق الصور لاختيار ورقة الواجب"
pb NSPhotoLibraryAddUsageDescription "لحفظ الحل كصورة في ألبوم الصور"
pb NSMicrophoneUsageDescription "للإجابة بالصوت"
/usr/libexec/PlistBuddy -c "Print" "$P" | head -60
npx @capacitor/assets generate --ios --iconBackgroundColor '#7C3AED' --splashBackgroundColor '#FFF7EE' --splashBackgroundColorDark '#1E1633' || echo "!! تعذّر توليد الأيقونات، سيستمر البناء بالأيقونة الافتراضية"
npx cap sync ios
if [ -d ios/App/App.xcworkspace ]; then SRC=(-workspace ios/App/App.xcworkspace); else SRC=(-project ios/App/App.xcodeproj); fi
xcodebuild "${SRC[@]}" -scheme App -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
APP=$(find build/Build/Products/Release-iphoneos -maxdepth 1 -name "*.app" | head -1)
echo "APP=$APP"
rm -rf Payload out && mkdir -p Payload out && cp -R "$APP" Payload/
zip -qry out/Muallim-v1.6-unsigned.ipa Payload
ls -la out
