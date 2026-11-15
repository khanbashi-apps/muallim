#!/usr/bin/env bash
set -euo pipefail
echo "== أدوات" ; node -v ; java -version 2>&1 | head -1
npm install --no-audit --no-fund
bash scripts/prepare-www.sh
npx cap add android
# صلاحية الكاميرا (لزر التصوير)
M=android/app/src/main/AndroidManifest.xml
grep -q 'android.permission.CAMERA' "$M" || sed -i 's#</manifest>#    <uses-permission android:name="android.permission.CAMERA" />\n</manifest>#' "$M"
npx @capacitor/assets generate --android --iconBackgroundColor '#7C3AED' --splashBackgroundColor '#FFF7EE' --splashBackgroundColorDark '#1E1633' || echo "!! تعذّر توليد الأيقونات، سيستمر البناء بالأيقونة الافتراضية"
npx cap sync android
if [ -n "${ANDROID_HOME:-}" ] && [ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null || true; fi
cd android && chmod +x gradlew && ./gradlew assembleDebug --no-daemon --stacktrace --warning-mode none
mkdir -p ../out && cp app/build/outputs/apk/debug/app-debug.apk ../out/Muallim-v1.3.apk
ls -la ../out
