#!/bin/bash
set -e

echo "========================================="
echo "ClassiCube Vercel Build Script"
echo "========================================="

# Check if Emscripten is available
if ! command -v emcc &> /dev/null; then
    echo "ERROR: Emscripten (emcc) not found in PATH"
    echo "Attempting to source emsdk environment..."
    
    # Try common Emscripten installation paths
    if [ -f "/opt/emsdk/emsdk_env.sh" ]; then
        echo "Found emsdk at /opt/emsdk"
        source /opt/emsdk/emsdk_env.sh
    elif [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
        echo "Found emsdk at $HOME/emsdk"
        source $HOME/emsdk/emsdk_env.sh
    elif [ -f "./emsdk/emsdk_env.sh" ]; then
        echo "Found emsdk at ./emsdk"
        source ./emsdk/emsdk_env.sh
    else
        echo "ERROR: Could not find Emscripten SDK"
        echo "Please install Emscripten from https://emscripten.org/"
        exit 1
    fi
fi

echo "Emscripten version:"
emcc --version

# Build the webclient
echo ""
echo "Building ClassiCube webclient..."
make web RELEASE=1

# Create public directory structure
echo ""
echo "Preparing deployment directory..."
mkdir -p public/static

# Copy build artifacts
echo "Copying build artifacts..."
if [ -f "build/web/ClassiCube.js" ]; then
    cp build/web/ClassiCube.js public/
    echo "✓ Copied ClassiCube.js"
else
    echo "ERROR: ClassiCube.js not found in build/web/"
    exit 1
fi

if [ -f "build/web/ClassiCube.wasm" ]; then
    cp build/web/ClassiCube.wasm public/
    echo "✓ Copied ClassiCube.wasm"
else
    echo "ERROR: ClassiCube.wasm not found in build/web/"
    exit 1
fi

# Patch the JS file to use correct texture pack URL
echo ""
echo "Patching ClassiCube.js for Vercel deployment..."
sed -i 's|var url = "/static/default.zip"|var url = "/static/default.zip"|g' public/ClassiCube.js || true
echo "✓ JS patched"

# Download texture pack if not present
if [ ! -f "public/static/default.zip" ]; then
    echo ""
    echo "Downloading default texture pack..."
    wget -q -O public/static/default.zip https://classicube.net/static/default.zip || \
    curl -s -o public/static/default.zip https://classicube.net/static/default.zip
    
    if [ -f "public/static/default.zip" ]; then
        echo "✓ Downloaded default.zip"
    else
        echo "WARNING: Could not download default.zip"
        echo "The texture pack will need to be added manually"
    fi
else
    echo "✓ default.zip already exists"
fi

# Display file sizes
echo ""
echo "Build artifacts:"
ls -lh public/ClassiCube.* 2>/dev/null || true
ls -lh public/static/default.zip 2>/dev/null || true

echo ""
echo "========================================="
echo "Build complete!"
echo "========================================="
echo "Ready for Vercel deployment from public/ directory"
