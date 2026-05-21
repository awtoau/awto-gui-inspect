#!/usr/bin/env python3
"""
AWTO GUI Inspect deployment and build management.

CLI coding standards: AI-agent friendly, JSON output, tail on errors, quiet by default.
See CLI_CODING_STANDARDS.md for design patterns.

Usage:
  python scripts/awto.py build flutter     # Build Flutter package
  python scripts/awto.py build linux       # Build Linux desktop app
  python scripts/awto.py build web         # Build web version
  python scripts/awto.py deploy linux      # Deploy to Linux system
  python scripts/awto.py deploy web        # Deploy web to server
  python scripts/awto.py run demo          # Run web demo
  python scripts/awto.py test              # Run all tests
  python scripts/awto.py clean             # Clean artifacts

Global options:
  --json               Output as JSON (for AI agents)
  --tail N             Show last N lines of logs on error
  --quiet              Suppress output on success
  --verbose            Show detailed output (overrides quiet)
"""

import argparse
import subprocess
import sys
import os
import shutil
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Optional, List

@dataclass
class CommandResult:
    """Structured command result."""
    command: str
    status: str  # success|error|skipped
    exit_code: int
    timestamp: str
    duration_ms: int
    output: dict
    errors: Optional[List[str]] = None
    log_tail: Optional[List[str]] = None

    def to_dict(self):
        return {k: v for k, v in asdict(self).items() if v is not None}

class AwtoDeployment:
    """AWTO GUI Inspect deployment manager (AI-agent friendly)."""

    def __init__(self, json_output=False, tail_lines=0, quiet=False, verbose=False, log_file=None):
        self.project_root = Path(__file__).parent.parent.absolute()
        self.example_dir = self.project_root / "example"
        self.build_dir = self.example_dir / "build"
        self.scripts_dir = self.project_root / "scripts"

        # CLI options
        self.json_output = json_output
        self.tail_lines = tail_lines
        self.quiet = quiet and not verbose  # verbose overrides quiet
        self.verbose = verbose
        self.log_file = log_file

        # Log buffer
        self.log_buffer = []

    def log(self, message, level="info"):
        """Log message with quiet/verbose handling."""
        self.log_buffer.append(message)

        if self.json_output:
            return  # Don't print in JSON mode

        if level in ["error", "warning"]:
            print(message)  # Always show errors/warnings
        elif not self.quiet or self.verbose:
            print(message)  # Show info if not quiet or if verbose

    def run_cmd(self, cmd, cwd=None, check=True, capture=True):
        """Run command with logging and error handling."""
        cwd = cwd or self.project_root

        if not self.quiet or self.verbose:
            self.log(f"  $ {' '.join(cmd)}")

        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=capture,
                text=True,
                check=False
            )

            if capture and result.stderr:
                self.log_buffer.extend(result.stderr.split('\n'))

            if check and result.returncode != 0:
                error_msg = f"Command failed: {' '.join(cmd)}"
                self.log(error_msg, "error")
                raise RuntimeError(error_msg)

            return result.returncode == 0, result
        except Exception as e:
            self.log(str(e), "error")
            raise

    def output_result(self, command_name, status, output_data=None, errors=None, exit_code=0, duration_ms=0):
        """Output result as JSON or human format."""
        result = CommandResult(
            command=command_name,
            status=status,
            exit_code=exit_code,
            timestamp=datetime.now().isoformat(),
            duration_ms=duration_ms,
            output=output_data or {},
            errors=errors,
            log_tail=self.log_buffer[-self.tail_lines:] if self.tail_lines > 0 else None
        )

        if self.json_output:
            print(json.dumps(result.to_dict(), indent=2))
        elif status == "error" and errors:
            for error in errors:
                self.log(error, "error")
            if self.tail_lines > 0:
                self.log("Error log tail:", "error")
                for line in result.log_tail or []:
                    self.log(f"  {line}", "error")

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

    def run_app_any(self):
        """Run app on default device."""
        print("▶️  Running app on default device...")
        os.chdir(self.example_dir)
        self.log("Available devices: run 'flutter devices' to see options")
        self.run_cmd(["flutter", "run"], check=False)

    def run_app_web(self, port=8080):
        """Run app on web."""
        print(f"🌐 Running app on web (localhost:{port})...")
        os.chdir(self.example_dir)
        self.log(f"  Opening browser at http://localhost:{port}")
        self.run_cmd(["flutter", "run", "-d", "chrome", f"--web-port={port}"], check=False)

    def run_app_linux(self, device=None):
        """Run app on Linux desktop."""
        print("🐧 Running app on Linux desktop...")
        os.chdir(self.example_dir)
        cmd = ["flutter", "run", "-d", "linux"]
        if device:
            cmd = ["flutter", "run", "-d", device]
        self.run_cmd(cmd, check=False)

    def run_app_android(self, device=None):
        """Run app on Android."""
        print("🤖 Running app on Android...")
        os.chdir(self.example_dir)
        cmd = ["flutter", "run", "-d", "android"]
        if device:
            cmd = ["flutter", "run", "-d", device]
        self.run_cmd(cmd, check=False)

    def run_app_ios(self, device=None):
        """Run app on iOS."""
        print("🍎 Running app on iOS...")
        os.chdir(self.example_dir)
        cmd = ["flutter", "run", "-d", "ios"]
        if device:
            cmd = ["flutter", "run", "-d", device]
        self.run_cmd(cmd, check=False)

    # ==================== Test Commands ====================

    def test_unit(self, test_file=None, coverage=False):
        """Run unit tests."""
        print("🧪 Running unit tests...")
        os.chdir(self.project_root)

        cmd = ["flutter", "test", "--unit-tests-only"]

        if test_file:
            cmd.append(f"test/{test_file}")
            self.log(f"  Testing: {test_file}")

        if coverage:
            cmd.append("--coverage")
            self.log("  Coverage enabled")

        return self.run_cmd(cmd, check=False)

    def test_widget(self, test_file=None, coverage=False):
        """Run widget tests."""
        print("🎨 Running widget tests...")
        os.chdir(self.project_root)

        cmd = ["flutter", "test"]

        if test_file:
            cmd.append(f"test/{test_file}")
            self.log(f"  Testing: {test_file}")
        else:
            cmd.append("test/")

        if coverage:
            cmd.append("--coverage")
            self.log("  Coverage enabled")

        return self.run_cmd(cmd, check=False)

    def test_integration(self, test_file=None):
        """Run integration tests."""
        print("🔗 Running integration tests...")
        os.chdir(self.example_dir)

        cmd = ["flutter", "test", "integration_test/"]

        if test_file:
            cmd.append(f"integration_test/{test_file}")
            self.log(f"  Testing: {test_file}")

        return self.run_cmd(cmd, check=False)

    def test_app(self):
        """Run the app (manual testing)."""
        print("▶️  Running app for manual testing...")
        os.chdir(self.example_dir)

        self.log("  Launching app for testing")
        self.log("  You can:")
        self.log("    • Open drawer to select test failure modes")
        self.log("    • Right-click widgets to inspect")
        self.log("    • Copy data as JSON/text")
        self.log("    • Log to AI with comments")
        self.log("")

        return self.run_cmd(["flutter", "run"], check=False)

    def test_flutter(self):
        """Run all Flutter tests."""
        print("🧪 Running all Flutter tests...")
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

    def test_all(self):
        """Run all tests."""
        print("🧪 Running all tests...\n")

        tests = [
            ("Unit tests", self.test_unit),
            ("Widget tests", self.test_widget),
            ("Lint checks", self.test_lint),
            ("Static analysis", self.test_analyze),
        ]

        passed = 0
        failed = 0

        for test_name, test_func in tests:
            print(f"\n{'='*50}")
            print(f"Running: {test_name}")
            print('='*50)
            try:
                if test_func():
                    passed += 1
                    self.log(f"✅ {test_name} passed")
                else:
                    failed += 1
                    self.log(f"❌ {test_name} failed")
            except Exception as e:
                failed += 1
                self.log(f"❌ {test_name} error: {e}", "error")

        print(f"\n{'='*50}")
        print(f"Test Summary: {passed} passed, {failed} failed")
        print('='*50)

        return failed == 0

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
BUILD Examples:
  python awto.py build flutter          # Build Flutter package
  python awto.py build linux            # Build Linux release
  python awto.py build web              # Build web version
  python awto.py build all              # Build all platforms

DEPLOY Examples:
  python awto.py deploy linux           # Deploy to Linux system
  python awto.py deploy web             # Deploy web version
  python awto.py deploy tarball         # Create tarball

TEST Examples:
  python awto.py test unit              # Run unit tests
  python awto.py test widget            # Run widget tests
  python awto.py test integration       # Run integration tests
  python awto.py test all               # Run all tests
  python awto.py test verify            # Full verification
  python awto.py test unit --coverage   # With coverage report

RUN Examples:
  python awto.py run demo web           # Web demo (localhost:8080)
  python awto.py run demo linux         # Linux desktop demo
  python awto.py run app web            # Run app on web
  python awto.py run app linux          # Run app on Linux
  python awto.py run test-app           # Manual testing mode

AI AGENT Examples:
  python awto.py build linux --json --tail 30
  python awto.py test verify --json --quiet
  python awto.py deploy linux --json --tail 50

Global Options:
  --json               Output as JSON (for AI agents/automation)
  --tail N             Show last N lines of logs on error (0=disabled)
  --quiet              Suppress output on success
  --verbose            Show detailed output (overrides quiet)
  --log-file FILE      Write logs to file
        """,
    )

    # Global options
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--tail", type=int, default=0, help="Tail N lines on error (default: 0)")
    parser.add_argument("--quiet", action="store_true", help="Suppress output on success")
    parser.add_argument("--verbose", action="store_true", help="Detailed output (overrides quiet)")
    parser.add_argument("--log-file", help="Write logs to file")

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
    run.add_argument(
        "action",
        choices=["demo", "app", "test-app"],
        help="What to run"
    )
    run.add_argument(
        "platform",
        nargs="?",
        choices=["web", "linux", "android", "ios"],
        help="Platform (for demo/app)"
    )
    run.add_argument("--port", type=int, default=8080, help="Web port (web only)")
    run.add_argument("--device", help="Device ID (android/iOS only)")

    # Test subcommands
    test = subparsers.add_parser("test", help="Run tests and validation")
    test.add_argument(
        "target",
        choices=["flutter", "unit", "widget", "integration", "lint", "analyze", "verify", "all"],
        help="Test type to run"
    )
    test.add_argument("--test-file", help="Specific test file to run")
    test.add_argument("--coverage", action="store_true", help="Generate coverage report")
    test.add_argument("--update-goldens", action="store_true", help="Update golden files")

    # Clean subcommands
    clean = subparsers.add_parser("clean", help="Clean artifacts")
    clean.add_argument("target", choices=["builds", "all"])

    # Status command
    subparsers.add_parser("status", help="Show project status")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    runner = AwtoDeployment(
        json_output=args.json,
        tail_lines=args.tail,
        quiet=args.quiet,
        verbose=args.verbose,
        log_file=args.log_file
    )

    start_time = datetime.now()

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
                else:
                    print("Platform required for demo (web or linux)")
                    return 1

            elif args.action == "app":
                if args.platform == "web":
                    runner.run_app_web(args.port)
                elif args.platform == "linux":
                    runner.run_app_linux(args.device)
                elif args.platform == "android":
                    runner.run_app_android(args.device)
                elif args.platform == "ios":
                    runner.run_app_ios(args.device)
                else:
                    runner.run_app_any()

            elif args.action == "test-app":
                runner.test_app()

        elif args.command == "test":
            if args.target == "unit":
                runner.test_unit(
                    test_file=args.test_file,
                    coverage=args.coverage
                )
            elif args.target == "widget":
                runner.test_widget(
                    test_file=args.test_file,
                    coverage=args.coverage
                )
            elif args.target == "integration":
                runner.test_integration(test_file=args.test_file)
            elif args.target == "flutter":
                runner.test_flutter()
            elif args.target == "lint":
                runner.test_lint()
            elif args.target == "analyze":
                runner.test_analyze()
            elif args.target == "verify":
                runner.test_verify()
            elif args.target == "all":
                runner.test_all()

        elif args.command == "clean":
            if args.target == "builds":
                runner.clean_builds()
            elif args.target == "all":
                runner.clean_all()

        elif args.command == "status":
            runner.status()

        duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
        runner.output_result(
            command_name=args.command,
            status="success",
            output_data={"message": f"{args.command} completed"},
            duration_ms=duration_ms
        )
        return 0

    except Exception as e:
        duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
        runner.output_result(
            command_name=args.command,
            status="error",
            errors=[str(e)],
            exit_code=1,
            duration_ms=duration_ms
        )
        return 1


if __name__ == "__main__":
    sys.exit(main())
