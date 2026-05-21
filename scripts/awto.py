#!/usr/bin/env python3
"""
AWTO GUI Inspect deployment and build management.

Unified CLI for building, testing, deploying, and managing
the awto_gui_inspect Flutter package across platforms.

Usage:
  python scripts/awto.py build flutter     # Build Flutter package
  python scripts/awto.py build linux       # Build Linux desktop app
  python scripts/awto.py build web         # Build web version
  python scripts/awto.py deploy linux      # Deploy to Linux system
  python scripts/awto.py deploy web        # Deploy web to server
  python scripts/awto.py run demo          # Run web demo
  python scripts/awto.py test              # Run all tests
  python scripts/awto.py clean             # Clean artifacts
"""

import argparse
import subprocess
import sys
import os
import shutil
import json
from pathlib import Path
from datetime import datetime

class AwtoDeployment:
    """AWTO GUI Inspect deployment manager."""

    def __init__(self):
        self.project_root = Path(__file__).parent.parent.absolute()
        self.example_dir = self.project_root / "example"
        self.build_dir = self.example_dir / "build"
        self.scripts_dir = self.project_root / "scripts"

    def run_cmd(self, cmd, cwd=None, check=True):
        """Run command and return result."""
        cwd = cwd or self.project_root
        print(f"  $ {' '.join(cmd)}")
        result = subprocess.run(cmd, cwd=cwd, capture_output=False, check=False)
        if check and result.returncode != 0:
            raise RuntimeError(f"Command failed: {' '.join(cmd)}")
        return result.returncode == 0

    # ==================== Build Commands ====================

    def build_flutter(self):
        """Build Flutter package."""
        print("📦 Building Flutter package...")
        os.chdir(self.project_root)
        return self.run_cmd(["python", "cli.py", "build"])

    def build_linux(self, release=True):
        """Build Linux desktop app."""
        print("🐧 Building Linux desktop app...")
        os.chdir(self.example_dir)

        # Check for Linux support
        if not (self.example_dir / "linux").exists():
            print("  Adding Linux support...")
            self.run_cmd(["flutter", "create", ".", "--platforms", "linux"])

        # Get dependencies
        print("  Getting dependencies...")
        self.run_cmd(["flutter", "pub", "get"])

        # Build
        mode = "--release" if release else ""
        cmd = ["flutter", "build", "linux"]
        if release:
            cmd.append("--release")
        self.run_cmd(cmd)

        print(f"✅ Linux app built: {self.example_dir}/build/linux/x64/release/bundle/awto_gui_inspect_example")
        return True

    def build_web(self):
        """Build web version."""
        print("🌐 Building web version...")
        os.chdir(self.example_dir)

        # Check for web support
        if not (self.example_dir / "web").exists():
            print("  Adding web support...")
            self.run_cmd(["flutter", "create", ".", "--platforms", "web"])

        # Get dependencies
        print("  Getting dependencies...")
        self.run_cmd(["flutter", "pub", "get"])

        # Build
        self.run_cmd(["flutter", "build", "web", "--release"])

        print(f"✅ Web app built: {self.example_dir}/build/web/")
        return True

    def build_all(self):
        """Build all platforms."""
        print("🏗️  Building all platforms...\n")
        return (
            self.build_flutter() and
            self.build_linux() and
            self.build_web()
        )

    # ==================== Deployment Commands ====================

    def deploy_linux(self, install_dir=None):
        """Deploy to Linux system."""
        print("📥 Deploying to Linux system...")

        if not self.build_linux():
            raise RuntimeError("Linux build failed")

        install_script = self.scripts_dir / "install-linux.sh"
        if not install_script.exists():
            raise FileNotFoundError(f"Install script not found: {install_script}")

        env = os.environ.copy()
        if install_dir:
            env["INSTALL_DIR"] = install_dir
            print(f"  Installing to: {install_dir}")

        os.chdir(self.project_root)
        result = subprocess.run(
            ["bash", str(install_script)],
            env=env,
            capture_output=False
        )

        if result.returncode == 0:
            print("✅ Linux deployment complete!")
            return True
        return False

    def deploy_web(self, output_dir=None):
        """Deploy web version."""
        print("🌐 Deploying web version...")

        if not self.build_web():
            raise RuntimeError("Web build failed")

        web_build = self.example_dir / "build/web"
        if not web_build.exists():
            raise FileNotFoundError(f"Web build not found: {web_build}")

        output = Path(output_dir) if output_dir else self.project_root / "deploy/web"
        output.parent.mkdir(parents=True, exist_ok=True)

        print(f"  Copying to: {output}")
        if output.exists():
            shutil.rmtree(output)
        shutil.copytree(web_build, output)

        print("✅ Web deployment complete!")
        print(f"   Ready for upload to web server")
        print(f"   Contents: {output}")
        return True

    def deploy_tarball(self, output_dir=None):
        """Create deployment tarball."""
        print("📦 Creating deployment tarball...")

        if not self.build_linux():
            raise RuntimeError("Linux build failed")

        bundle_dir = self.example_dir / "build/linux/x64/release/bundle"
        if not bundle_dir.exists():
            raise FileNotFoundError(f"Bundle not found: {bundle_dir}")

        output = Path(output_dir) if output_dir else self.project_root / "deploy"
        output.mkdir(parents=True, exist_ok=True)

        tarball = output / "awto-gui-inspect-linux.tar.gz"
        print(f"  Creating: {tarball}")

        # Create tarball
        os.chdir(self.example_dir / "build/linux/x64/release")
        result = subprocess.run(
            ["tar", "-czf", str(tarball), "bundle/"],
            capture_output=False
        )

        if result.returncode == 0:
            size_mb = tarball.stat().st_size / (1024 * 1024)
            print(f"✅ Tarball created: {size_mb:.1f} MB")
            print(f"   Location: {tarball}")
            return True
        return False

    # ==================== Runtime Commands ====================

    def run_demo_web(self, port=8080):
        """Run web demo."""
        print(f"🌐 Starting web demo on http://localhost:{port}...")

        os.chdir(self.example_dir)

        # Check for web support
        if not (self.example_dir / "web").exists():
            print("  Adding web support...")
            self.run_cmd(["flutter", "create", ".", "--platforms", "web"])

        print(f"\n📍 Open your browser: http://localhost:{port}")
        print("🎮 Try:")
        print("   • Right-click buttons to inspect")
        print("   • Hover to see debug overlay")
        print("   • Copy JSON/text data")
        print("   • Log to AI with comments\n")

        self.run_cmd(
            ["flutter", "run", "-d", "chrome", f"--web-port={port}"],
            check=False
        )

    def run_demo_linux(self):
        """Run Linux demo."""
        print("🐧 Starting Linux demo...")

        binary = self.example_dir / "build/linux/x64/release/bundle/awto_gui_inspect_example"

        if not binary.exists():
            print("  Building Linux app first...")
            if not self.build_linux():
                raise RuntimeError("Linux build failed")

        print(f"  Launching: {binary}\n")
        subprocess.run([str(binary)], check=False)

    # ==================== Test Commands ====================

    def test_flutter(self):
        """Run Flutter tests."""
        print("🧪 Running Flutter tests...")
        os.chdir(self.project_root)
        return self.run_cmd(["python", "cli.py", "test"], check=False)

    def test_lint(self):
        """Run linting."""
        print("🎯 Running linting checks...")
        os.chdir(self.project_root)
        return self.run_cmd(["python", "cli.py", "lint"], check=False)

    def test_analyze(self):
        """Run static analysis."""
        print("🔍 Running static analysis...")
        os.chdir(self.project_root)
        return self.run_cmd(["python", "cli.py", "analyze"], check=False)

    def test_verify(self):
        """Run full verification suite."""
        print("✅ Running full verification...")
        os.chdir(self.project_root)
        return self.run_cmd(["python", "cli.py", "verify"], check=False)

    # ==================== Clean Commands ====================

    def clean_builds(self):
        """Clean build artifacts."""
        print("🧹 Cleaning build artifacts...")

        dirs_to_clean = [
            self.build_dir,
            self.project_root / ".dart_tool",
            self.project_root / "deploy",
        ]

        for dir_path in dirs_to_clean:
            if dir_path.exists():
                print(f"  Removing {dir_path.relative_to(self.project_root)}")
                shutil.rmtree(dir_path, ignore_errors=True)

        print("✅ Clean complete")
        return True

    def clean_all(self):
        """Full clean."""
        print("🧹 Full clean...")
        os.chdir(self.project_root)
        self.run_cmd(["python", "cli.py", "clean"], check=False)
        self.clean_builds()
        return True

    # ==================== Info Commands ====================

    def status(self):
        """Show project status."""
        print("📊 AWTO GUI Inspect Status")
        print("=" * 50)

        # Version
        pubspec = self.project_root / "pubspec.yaml"
        if pubspec.exists():
            with open(pubspec) as f:
                for line in f:
                    if line.startswith("version:"):
                        version = line.split(":")[-1].strip()
                        print(f"Version: {version}")
                        break

        # Builds
        builds = {
            "Flutter": self.project_root / "lib/awto_gui_inspect.dart",
            "Linux": self.example_dir / "build/linux/x64/release/bundle/awto_gui_inspect_example",
            "Web": self.example_dir / "build/web/index.html",
        }

        print("\nBuilds:")
        for name, path in builds.items():
            status = "✅" if path.exists() else "❌"
            print(f"  {status} {name}: {path.exists()}")

        # Scripts
        print("\nScripts:")
        scripts = [
            ("run-demo.sh", self.scripts_dir / "run-demo.sh"),
            ("install-linux.sh", self.scripts_dir / "install-linux.sh"),
            ("cli.py", self.project_root / "cli.py"),
        ]

        for name, path in scripts:
            status = "✅" if path.exists() else "❌"
            print(f"  {status} {name}: {path.exists()}")

        # Git
        print("\nRepository:")
        os.chdir(self.project_root)
        result = subprocess.run(
            ["git", "log", "--oneline", "-1"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"  Latest: {result.stdout.strip()}")

        return True


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="AWTO GUI Inspect deployment and build management",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python awto.py build flutter          # Build Flutter package
  python awto.py build linux --release  # Build Linux release
  python awto.py build web              # Build web version
  python awto.py build all              # Build all platforms

  python awto.py deploy linux           # Deploy to Linux system
  python awto.py deploy web             # Deploy web version
  python awto.py deploy tarball         # Create deployment tarball

  python awto.py run demo web           # Run web demo
  python awto.py run demo linux         # Run Linux demo

  python awto.py test flutter           # Run tests
  python awto.py test verify            # Full verification

  python awto.py clean builds           # Clean artifacts
  python awto.py clean all              # Full clean

  python awto.py status                 # Show project status
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Build subcommands
    build = subparsers.add_parser("build", help="Build for platforms")
    build.add_argument("target", choices=["flutter", "linux", "web", "all"])
    build.add_argument("--release", action="store_true", default=True)

    # Deploy subcommands
    deploy = subparsers.add_parser("deploy", help="Deploy to systems")
    deploy.add_argument("target", choices=["linux", "web", "tarball"])
    deploy.add_argument("--output", "-o", help="Output directory")

    # Run subcommands
    run = subparsers.add_parser("run", help="Run applications")
    run.add_argument("action", choices=["demo"])
    run.add_argument("platform", choices=["web", "linux"])
    run.add_argument("--port", type=int, default=8080, help="Web port (web only)")

    # Test subcommands
    test = subparsers.add_parser("test", help="Run tests")
    test.add_argument("target", choices=["flutter", "lint", "analyze", "verify"])

    # Clean subcommands
    clean = subparsers.add_parser("clean", help="Clean artifacts")
    clean.add_argument("target", choices=["builds", "all"])

    # Status command
    subparsers.add_parser("status", help="Show project status")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    runner = AwtoDeployment()

    try:
        if args.command == "build":
            if args.target == "flutter":
                runner.build_flutter()
            elif args.target == "linux":
                runner.build_linux()
            elif args.target == "web":
                runner.build_web()
            elif args.target == "all":
                runner.build_all()

        elif args.command == "deploy":
            if args.target == "linux":
                runner.deploy_linux(args.output)
            elif args.target == "web":
                runner.deploy_web(args.output)
            elif args.target == "tarball":
                runner.deploy_tarball(args.output)

        elif args.command == "run":
            if args.action == "demo":
                if args.platform == "web":
                    runner.run_demo_web(args.port)
                elif args.platform == "linux":
                    runner.run_demo_linux()

        elif args.command == "test":
            if args.target == "flutter":
                runner.test_flutter()
            elif args.target == "lint":
                runner.test_lint()
            elif args.target == "analyze":
                runner.test_analyze()
            elif args.target == "verify":
                runner.test_verify()

        elif args.command == "clean":
            if args.target == "builds":
                runner.clean_builds()
            elif args.target == "all":
                runner.clean_all()

        elif args.command == "status":
            runner.status()

        return 0

    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
