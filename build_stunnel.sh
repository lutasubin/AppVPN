#!/bin/bash

# Script để build Stunnel binary cho Android
# Chạy script này để tạo Stunnel binary thực cho các architecture khác nhau

echo "🔧 Building Stunnel for Android..."

# Tạo thư mục build
mkdir -p stunnel_build
cd stunnel_build

# Clone Stunnel source
echo "📥 Cloning Stunnel source..."
git clone https://github.com/mtrojnar/stunnel.git
cd stunnel

# Các architecture cần build
ARCHS=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")
NDK_PATHS=("aarch64-linux-android" "armv7a-linux-androideabi" "i686-linux-android" "x86_64-linux-android")

for i in "${!ARCHS[@]}"; do
    ARCH=${ARCHS[$i]}
    NDK_PATH=${NDK_PATHS[$i]}
    
    echo "🔨 Building for $ARCH..."
    
    # Tạo thư mục build
    mkdir -p build_$ARCH
    cd build_$ARCH
    
    # Configure với Android NDK
    ../configure \
        --host=$NDK_PATH \
        --prefix=/usr/local \
        --with-ssl=/usr/local \
        --disable-shared \
        --enable-static
    
    # Build
    make -j$(nproc)
    
    # Copy binary
    cp src/stunnel ../../../android/app/src/main/jniLibs/$ARCH/libstunnel.so
    
    cd ..
done

echo "✅ Stunnel binaries built successfully!"
echo "📁 Binaries located in: android/app/src/main/jniLibs/" 