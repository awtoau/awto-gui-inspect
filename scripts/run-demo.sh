#!/bin/bash
# Run the awto_gui_inspect Flutter example demo

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$PROJECT_ROOT/example"

echo "🚀 Starting awto_gui_inspect demo..."
echo ""

# Add web support if not present
if [ ! -d "$EXAMPLE_DIR/web" ]; then
  echo "📦 Adding web support..."
  cd "$EXAMPLE_DIR"
  flutter create . --platforms web > /dev/null 2>&1
  echo "✅ Web support added"
  echo ""
fi

# Get dependencies
echo "📥 Getting dependencies..."
cd "$EXAMPLE_DIR"
flutter pub get > /dev/null 2>&1
echo "✅ Dependencies ready"
echo ""

# Run the app
echo "🎮 Launching Flutter app on web..."
echo ""
echo "📍 URL: http://localhost:8080"
echo ""
echo "✨ Features to try:"
echo "  • Right-click any button to inspect"
echo "  • Hover to see debug overlay with ID"
echo "  • Copy as JSON or text"
echo "  • Log to AI with comments"
echo "  • Grid overlay and crosshair cursor"
echo "  • Status line showing position"
echo ""
echo "⌨️  Flutter commands:"
echo "  r = Hot reload"
echo "  R = Hot restart"
echo "  d = Detach"
echo "  q = Quit"
echo ""

flutter run -d chrome --web-port=8080
