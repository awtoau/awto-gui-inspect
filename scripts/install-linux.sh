#!/bin/bash
# Install awto_gui_inspect example app for Linux

set -e

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
APP_NAME="awto-gui-inspect"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../example/build/linux/x64/release/bundle" && pwd)"

echo "📦 Installing awto_gui_inspect to $INSTALL_DIR..."

# Create directory if not exists
mkdir -p "$INSTALL_DIR"

# Copy the entire bundle
if [ -d "$BUILD_DIR" ]; then
  APP_DIR="$INSTALL_DIR/$APP_NAME"
  rm -rf "$APP_DIR" 2>/dev/null || true
  cp -r "$BUILD_DIR" "$APP_DIR"

  # Create executable wrapper
  cat > "$INSTALL_DIR/$APP_NAME-run" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$SCRIPT_DIR/awto-gui-inspect"
exec "$APP_DIR/awto_gui_inspect_example" "$@"
EOF

  chmod +x "$INSTALL_DIR/$APP_NAME-run"
  chmod +x "$APP_DIR/awto_gui_inspect_example"

  echo "✅ Installation complete!"
  echo ""
  echo "To run:"
  echo "  $INSTALL_DIR/$APP_NAME-run"
  echo ""
  echo "Or add to PATH and run:"
  echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
  echo "  awto-gui-inspect-run"
else
  echo "❌ Build directory not found at $BUILD_DIR"
  echo "Run: flutter build linux --release first"
  exit 1
fi
