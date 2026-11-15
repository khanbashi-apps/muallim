#!/usr/bin/env bash
# ينسخ ملفات الموقع إلى مجلد www الذي يغلّفه Capacitor، ومعها مكتبة capacitor.js لتسجيل الإضافات
set -euo pipefail
rm -rf www && mkdir -p www
cp index.html manifest.webmanifest sw.js www/
cp -r icons www/
cp node_modules/@capacitor/core/dist/capacitor.js www/capacitor.js
