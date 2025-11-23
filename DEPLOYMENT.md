# ClassiCube Marketcraft - Vercel Deployment Guide

This guide covers deploying ClassiCube Marketcraft to Vercel as a static web application.

## Prerequisites

1. **Emscripten SDK** (for building)
   - Required to compile C code to WebAssembly
   - Installation: https://emscripten.org/docs/getting_started/downloads.html
   
2. **Vercel Account** (for deployment)
   - Sign up at https://vercel.com/

## Quick Start

### Option 1: Automatic Deployment via GitHub Actions

The repository is configured for automatic deployment when you push to the main branch.

1. **Configure GitHub Secrets**
   
   Go to your repository settings and add these secrets:
   - `VERCEL_TOKEN`: Get from https://vercel.com/account/tokens
   - `VERCEL_ORG_ID`: Found in Vercel project settings
   - `VERCEL_PROJECT_ID`: Found in Vercel project settings

2. **Push to main branch**
   
   The GitHub Actions workflow will automatically:
   - Build the WebAssembly version
   - Download required assets
   - Deploy to Vercel

### Option 2: Manual Deployment via Vercel CLI

1. **Build the project**
   ```bash
   # Install Emscripten if not already installed
   git clone https://github.com/emscripten-core/emsdk.git
   cd emsdk
   ./emsdk install latest
   ./emsdk activate latest
   source ./emsdk_env.sh
   cd ..
   
   # Build ClassiCube for web
   bash scripts/build-for-vercel.sh
   ```

2. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

3. **Deploy**
   ```bash
   vercel --prod
   ```

### Option 3: Deploy via Vercel Dashboard

1. Build the project locally (see Option 2, step 1)
2. Go to https://vercel.com/new
3. Import your GitHub repository
4. Configure build settings:
   - Framework Preset: Other
   - Build Command: `bash scripts/build-for-vercel.sh`
   - Output Directory: `public`
5. Deploy

## Configuration Files

### vercel.json

Configures Vercel deployment settings:
- Routes and redirects
- Cache headers for optimal performance
- CORS headers for WebAssembly
- MIME types

### package.json

Defines the build script used by Vercel:
```json
{
  "scripts": {
    "build": "bash scripts/build-for-vercel.sh"
  }
}
```

### .vercelignore

Excludes unnecessary files from deployment to reduce deployment size.

## Build Script

The `scripts/build-for-vercel.sh` script:
1. Checks for Emscripten installation
2. Builds the WebAssembly version with optimizations
3. Copies files to the `public/` directory
4. Downloads the texture pack
5. Applies necessary patches

## File Structure

```
public/                    # Deployment directory
├── index.html            # Main HTML page
├── ClassiCube.js         # Generated JS glue code
├── ClassiCube.wasm       # Generated WebAssembly binary
└── static/
    └── default.zip       # Texture pack
```

## Customization

### Connecting to a Server

Edit `public/index.html` and modify the `Module.arguments`:

```javascript
// Singleplayer (default)
arguments: ['Player']

// Multiplayer
arguments: ['username', 'mppass', 'server.example.com', '25565']
```

### Styling

The HTML includes embedded CSS. You can:
- Edit the `<style>` section in `public/index.html`
- Create a separate CSS file in `public/static/`

### Texture Pack

To use a custom texture pack:
1. Place your texture pack in `public/static/`
2. Update the URL in ClassiCube.js if needed

## Optimization

The build is configured for maximum optimization:
- `-O3` optimization level
- Link-Time Optimization (LTO)
- Brotli compression (automatic on Vercel)
- Aggressive caching headers

## Troubleshooting

### Build fails with "emcc not found"

Install Emscripten SDK:
```bash
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

### Texture pack not loading

Check that `public/static/default.zip` exists and is accessible.

### WebAssembly not loading

1. Check browser console for errors
2. Verify MIME type is `application/wasm`
3. Check CORS headers in vercel.json

### Deployment size too large

Vercel has a 100MB limit. To reduce size:
1. Ensure RELEASE=1 is used in build
2. Remove unnecessary files via .vercelignore
3. Consider hosting large assets externally

## Performance

Expected metrics:
- WASM file size: 1-3MB (compressed)
- JS file size: 500KB-1MB (compressed)
- Initial load time: 2-5 seconds (on 4G)
- FPS: 60fps on desktop, 30fps on mobile

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [ClassiCube Website](https://www.classicube.net/)
- [Emscripten Documentation](https://emscripten.org/docs/)
- [Full Deployment Analysis](doc/vercel-static-deployment-analysis.md)

## Support

For issues related to:
- **Building**: Check the Emscripten setup
- **Deployment**: Check Vercel documentation
- **Game functionality**: Report to ClassiCube project

## License

See `license.txt` in the repository root.
