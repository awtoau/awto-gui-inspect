# Linux Deployment Guide

## Quick Start

### 1. Install from Tarball

```bash
# Download the release
tar xzf awto-gui-inspect-linux.tar.gz

# Run directly
./bundle/awto_gui_inspect_example
```

### 2. Install to System

```bash
# Using the installation script
bash scripts/install-linux.sh

# Or specify custom install directory
INSTALL_DIR=/opt/awto ./scripts/install-linux.sh

# Run from anywhere
$HOME/.local/bin/awto-gui-inspect-run
```

### 3. Add to Desktop Menu

Create `~/.local/share/applications/awto-gui-inspect.desktop`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=AWTO GUI Inspector
Comment=Flutter GUI Inspection & AI Handoff
Exec=$HOME/.local/bin/awto-gui-inspect-run
Icon=flutter
Categories=Development;Utility;
Terminal=false
```

Then reload applications:
```bash
update-desktop-database ~/.local/share/applications/
```

## Requirements

### Linux (Fedora/Ubuntu/Debian)

**Fedora:**
```bash
sudo dnf install gtk3 libappindicator-gtk3
```

**Ubuntu/Debian:**
```bash
sudo apt-get install libgtk-3-0 libappindicator3-1
```

### Arch Linux
```bash
sudo pacman -S gtk3 libappindicator-gtk3
```

## Build from Source

```bash
# Clone the repository
git clone https://github.com/awtoau/awto-gui-inspect.git
cd awto-gui-inspect/example

# Build for Linux
flutter build linux --release

# Run
./build/linux/x64/release/bundle/awto_gui_inspect_example
```

## Application Contents

The Linux build includes:

```
bundle/
├── awto_gui_inspect_example          # Main executable
├── data/                              # Application data
│   └── flutter_assets/
│       └── ...
└── lib/                               # Libraries
    ├── libflutter.so                 # Flutter engine
    ├── libapp.so                     # App library
    └── ...
```

## Features Available on Linux Desktop

✅ Full GUI inspection system:
- Grid overlay
- Crosshair cursor
- Hit box visualization
- Object debug IDs
- Status line with position tracking
- Right-click context menu
- Copy as JSON/text
- AI logging with comments
- Safety metadata display

✅ All v0.1.0 features working

## Troubleshooting

### App won't start
```bash
# Check dependencies
ldd ./bundle/awto_gui_inspect_example

# Install missing libraries
# (See Requirements section above)
```

### Display issues
- Ensure X11 or Wayland display is available
- Check `$DISPLAY` variable
- May not run in headless environments

### Missing cursor theme
```bash
# Install theme
sudo dnf install adwaita-cursor-theme
```

## Distribution

### Create Snap Package (Optional)

```bash
sudo apt install snapcraft
snapcraft
# (Requires snapcraft.yaml - advanced)
```

### Create AppImage (Alternative)

Use [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy):

```bash
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage
./linuxdeploy-x86_64.AppImage --appdir=AppDir --executable=./bundle/awto_gui_inspect_example --desktop-file=awto-gui-inspect.desktop
```

## Performance

- Startup: ~2-3 seconds
- Memory: ~100-150 MB
- Responsive overlays and inspection

## Development

To modify and rebuild:

```bash
cd example
flutter run -d linux              # Development mode
flutter build linux --release     # Production build
```

## Support

For issues:
1. Check [README.md](README.md)
2. Review [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)
3. Open issue at: https://github.com/awtoau/awto-gui-inspect/issues

## Version

- **App Version**: 0.1.0
- **Flutter**: 3.41.9
- **Dart**: 3.11.5

## License

AWTO Project License
