#!/bin/bash

# Script để tải Stunnel binary cho Android
echo "🔧 Downloading Stunnel binaries for Android..."

# Tạo thư mục
mkdir -p stunnel_binaries
cd stunnel_binaries

# Danh sách các nguồn có thể tải Stunnel
SOURCES=(
    "https://github.com/guardianproject/stunnel-android/releases/download/v5.70/stunnel-android-v5.70-arm64-v8a.zip"
    "https://github.com/guardianproject/stunnel-android/releases/download/v5.70/stunnel-android-v5.70-armeabi-v7a.zip"
    "https://github.com/guardianproject/stunnel-android/releases/download/v5.70/stunnel-android-v5.70-x86.zip"
    "https://github.com/guardianproject/stunnel-android/releases/download/v5.70/stunnel-android-v5.70-x86_64.zip"
)

# Tên file tương ứng
NAMES=(
    "stunnel-arm64-v8a.zip"
    "stunnel-armeabi-v7a.zip"
    "stunnel-x86.zip"
    "stunnel-x86_64.zip"
)

echo "📥 Attempting to download Stunnel binaries..."

for i in "${!SOURCES[@]}"; do
    SOURCE=${SOURCES[$i]}
    NAME=${NAMES[$i]}
    
    echo "🔗 Trying: $NAME"
    curl -L -o "$NAME" "$SOURCE" 2>/dev/null
    
    if [ -f "$NAME" ] && [ $(stat -c%s "$NAME") -gt 1000 ]; then
        echo "✅ Downloaded: $NAME"
    else
        echo "❌ Failed to download: $NAME"
        rm -f "$NAME"
    fi
done

echo ""
echo "📋 Alternative sources to try manually:"
echo "1. https://github.com/guardianproject/stunnel-android/releases"
echo "2. https://github.com/mtrojnar/stunnel/releases"
echo "3. https://www.stunnel.org/downloads.html"
echo ""
echo "🔧 Manual installation steps:"
echo "1. Download stunnel binary for your architecture"
echo "2. Extract and rename to 'libstunnel.so'"
echo "3. Copy to android/app/src/main/jniLibs/[architecture]/"
echo ""
echo "📁 Target directories:"
echo "- android/app/src/main/jniLibs/arm64-v8a/libstunnel.so"
echo "- android/app/src/main/jniLibs/armeabi-v7a/libstunnel.so"
echo "- android/app/src/main/jniLibs/x86/libstunnel.so"
echo "- android/app/src/main/jniLibs/x86_64/libstunnel.so" 