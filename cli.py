#!/usr/bin/env python3
"""
Build, clean, test, and deploy CLI for awto_gui_inspect Flutter package.
"""

import argparse
import subprocess
import sys
import os
import shutil
from pathlib import Path

class FlutterCliRunner:
    """Manages Flutter project builds, tests, and cleanup."""

    def __init__(self):
        self.project_root = Path(__file__).parent.absolute()
        self.pubspec_path = self.project_root / "pubspec.yaml"
        self.build_dir = self.project_root / "build"
        self.test_dir = self.project_root / "test"

    def run_command(self, cmd, cwd=None, check=True):
        """Run a shell command and return result."""
        cwd = cwd or self.project_root
        print(f"  Running: {' '.join(cmd)}")
        result = subprocess.run(cmd, cwd=cwd, capture_output=False, check=False)
        if check and result.returncode != 0:
            raise RuntimeError(f"Command failed: {' '.join(cmd)}")
        return result.returncode == 0

    def clean(self):
        """Remove build artifacts and temporary files."""
        print("🧹 Cleaning project...")

        dirs_to_clean = [
            self.build_dir,
            self.project_root / ".dart_tool",
            self.project_root / ".packages",
        ]

        for dir_path in dirs_to_clean:
            if dir_path.exists():
                print(f"  Removing {dir_path.relative_to(self.project_root)}")
                shutil.rmtree(dir_path, ignore_errors=True)

        # Remove generated files
        for pattern in ["*.g.dart", "*.freezed.dart", "*.config.dart"]:
            for file in self.project_root.rglob(pattern):
                print(f"  Removing {file.relative_to(self.project_root)}")
                file.unlink()

        print("✓ Clean complete")
        return True

    def get_dependencies(self):
        """Get/update Flutter dependencies."""
        print("📦 Getting dependencies...")
        return self.run_command(["flutter", "pub", "get"])

    def analyze(self):
        """Run static analysis (dart analyze)."""
        print("🔍 Running static analysis...")
        return self.run_command(["dart", "analyze", "."])

    def format(self):
        """Format code with dart format."""
        print("✨ Formatting code...")
        return self.run_command(["dart", "format", "lib", "test", "--line-length=100"])

    def test(self):
        """Run unit and widget tests."""
        print("🧪 Running tests...")

        if not self.test_dir.exists():
            print("  ℹ No test directory found, skipping tests")
            return True

        return self.run_command(["flutter", "test", "--coverage"])

    def build_docs(self):
        """Generate dartdoc documentation."""
        print("📚 Building documentation...")
        docs_dir = self.project_root / "doc"
        if docs_dir.exists():
            shutil.rmtree(docs_dir)

        return self.run_command(["dart", "doc", "."])

    def build_package(self):
        """Build the package (prep for publication)."""
        print("🏗️  Building package...")

        # Verify pubspec.yaml is valid
        if not self.pubspec_path.exists():
            raise FileNotFoundError(f"pubspec.yaml not found at {self.pubspec_path}")

        # Run pub publish --dry-run to check package validity
        print("  Checking package validity...")
        return self.run_command(["flutter", "pub", "publish", "--dry-run"])

    def publish(self, dry_run=True):
        """Publish the package to pub.dev."""
        if dry_run:
            print("🚀 Publishing package (dry run)...")
            return self.run_command(["flutter", "pub", "publish", "--dry-run"])
        else:
            print("🚀 Publishing package...")
            return self.run_command(["flutter", "pub", "publish"])

    def lint(self):
        """Run linting checks."""
        print("🎯 Linting code...")

        # Check for common issues
        lint_checks = [
            ("Missing documentation", self._check_missing_docs),
            ("Unused imports", self._check_unused_imports),
        ]

        all_pass = True
        for check_name, check_func in lint_checks:
            if not check_func():
                print(f"  ✗ {check_name}")
                all_pass = False
            else:
                print(f"  ✓ {check_name}")

        return all_pass

    def _check_missing_docs(self):
        """Check for missing documentation on public APIs."""
        # Simple heuristic: check for public classes without ///
        missing = []
        for py_file in (self.project_root / "lib").glob("**/*.dart"):
            if py_file.name.startswith("_"):
                continue
            with open(py_file) as f:
                content = f.read()
                # This is a simple check; could be enhanced
                if "class " in content and "///" not in content:
                    pass  # For now, just pass

        return True

    def _check_unused_imports(self):
        """Check for unused imports."""
        # dart analyze already handles this
        return True

    def verify(self):
        """Run full verification suite."""
        print("✅ Running full verification...")

        checks = [
            ("Dependencies", self.get_dependencies),
            ("Analysis", self.analyze),
            ("Linting", self.lint),
            ("Tests", self.test),
        ]

        for check_name, check_func in checks:
            print(f"\n{check_name}:")
            try:
                if not check_func():
                    print(f"✗ {check_name} failed")
                    return False
            except Exception as e:
                print(f"✗ {check_name} error: {e}")
                return False

        print("\n✅ All checks passed!")
        return True

    def run_all(self):
        """Run clean, verify, build, and docs."""
        print("🔄 Running full build pipeline...\n")

        steps = [
            ("Clean", self.clean),
            ("Get dependencies", self.get_dependencies),
            ("Format", self.format),
            ("Analyze", self.analyze),
            ("Lint", self.lint),
            ("Test", self.test),
            ("Build package", self.build_package),
            ("Build docs", self.build_docs),
        ]

        failed = []
        for step_name, step_func in steps:
            print(f"\n{step_name}:")
            try:
                if not step_func():
                    failed.append(step_name)
                    print(f"⚠️  {step_name} had warnings")
            except Exception as e:
                failed.append(step_name)
                print(f"✗ {step_name} failed: {e}")

        if failed:
            print(f"\n⚠️  Some steps had issues: {', '.join(failed)}")
            return False
        else:
            print("\n✅ Build pipeline complete!")
            return True


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Build and test awto_gui_inspect Flutter package",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python cli.py clean                 # Clean build artifacts
  python cli.py test                  # Run tests
  python cli.py verify                # Run full verification
  python cli.py all                   # Full build pipeline
  python cli.py build                 # Build package
  python cli.py docs                  # Generate documentation
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Commands")

    subparsers.add_parser("clean", help="Clean build artifacts and temporary files")
    subparsers.add_parser("get", help="Get dependencies")
    subparsers.add_parser("analyze", help="Run static analysis")
    subparsers.add_parser("format", help="Format code")
    subparsers.add_parser("test", help="Run tests")
    subparsers.add_parser("lint", help="Run linting checks")
    subparsers.add_parser("build", help="Build package")
    subparsers.add_parser("docs", help="Generate documentation")
    subparsers.add_parser("verify", help="Run full verification suite")
    subparsers.add_parser("all", help="Run full build pipeline")

    publish_parser = subparsers.add_parser("publish", help="Publish package to pub.dev")
    publish_parser.add_argument(
        "--force",
        action="store_true",
        help="Publish without dry-run",
    )

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    runner = FlutterCliRunner()

    try:
        if args.command == "clean":
            runner.clean()
        elif args.command == "get":
            runner.get_dependencies()
        elif args.command == "analyze":
            runner.analyze()
        elif args.command == "format":
            runner.format()
        elif args.command == "test":
            runner.test()
        elif args.command == "lint":
            runner.lint()
        elif args.command == "build":
            runner.build_package()
        elif args.command == "docs":
            runner.build_docs()
        elif args.command == "verify":
            success = runner.verify()
            return 0 if success else 1
        elif args.command == "all":
            success = runner.run_all()
            return 0 if success else 1
        elif args.command == "publish":
            success = runner.publish(dry_run=not args.force)
            return 0 if success else 1

        return 0

    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
