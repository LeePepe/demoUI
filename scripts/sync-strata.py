#!/usr/bin/env python3
"""Synchronize demoUI's shared-design-system revision."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from typing import Callable


SHA_PATTERN = re.compile(r"^[0-9a-f]{40}$")
PACKAGE_PATTERN = re.compile(
    r'(\.package\s*\(\s*url:\s*"https://github\.com/LeePepe/shared-design-system\.git"'
    r'\s*,\s*revision:\s*")[0-9a-f]{40}(")',
    re.DOTALL,
)
RESOLVED_PATTERN = re.compile(
    r'("identity"\s*:\s*"shared-design-system"\s*,.*?'
    r'"revision"\s*:\s*")[0-9a-f]{40}(")',
    re.DOTALL,
)
GUIDE_PIN_PATTERNS = (
    re.compile(r"(LeePepe/shared-design-system@)[0-9a-f]{40}"),
    re.compile(r"(LeePepe/shared-design-system/tree/)[0-9a-f]{40}"),
)


class SyncError(Exception):
    """An expected synchronization failure."""


def repository_root() -> Path:
    return Path(__file__).resolve().parent.parent


def validate_sha(value: str) -> str:
    if not SHA_PATTERN.fullmatch(value):
        raise SyncError("shared-design-system SHA must be 40 lowercase hexadecimal characters")
    return value


def read_metadata(path: Path) -> dict:
    try:
        metadata = json.loads(path.read_text(encoding="utf-8"))
        dependency = metadata["dependencies"]["shared-design-system"]
        validate_sha(dependency["version"])
    except (OSError, KeyError, TypeError, json.JSONDecodeError, SyncError) as error:
        raise SyncError(f"unable to read {path}: {error}") from error
    return metadata


def replace_package_revision(text: str, sha: str) -> str:
    updated, count = PACKAGE_PATTERN.subn(rf"\g<1>{sha}\g<2>", text)
    if count != 1:
        raise SyncError("expected exactly one shared-design-system revision in app/Package.swift")
    return updated


def replace_resolved_revision(text: str, sha: str) -> str:
    updated, count = RESOLVED_PATTERN.subn(rf"\g<1>{sha}\g<2>", text, count=1)
    if count != 1:
        raise SyncError("expected one shared-design-system revision in app/Package.resolved")
    return updated


def update_guide_revision(text: str, sha: str) -> str:
    marker = "## Complete shared protocol snapshot\n"
    if marker not in text:
        return text
    head, snapshot = text.split(marker, 1)
    for pattern in GUIDE_PIN_PATTERNS:
        head = pattern.sub(rf"\g<1>{sha}", head)
    return head + marker + snapshot


def shared_revisions(root: Path) -> dict[str, str]:
    metadata = read_metadata(root / ".github/repo-contract.json")
    package_text = (root / "app/Package.swift").read_text(encoding="utf-8")
    resolved_text = (root / "app/Package.resolved").read_text(encoding="utf-8")
    package_match = PACKAGE_PATTERN.search(package_text)
    resolved_match = RESOLVED_PATTERN.search(resolved_text)
    if package_match is None:
        raise SyncError("expected one shared-design-system revision in app/Package.swift")
    if resolved_match is None:
        raise SyncError("expected one shared-design-system revision in app/Package.resolved")
    revisions = {
        ".github/repo-contract.json": metadata["dependencies"]["shared-design-system"]["version"],
        "app/Package.swift": package_match.group(0).split('"')[-2],
        "app/Package.resolved": resolved_match.group(0).split('"')[-2],
    }
    for path, revision in revisions.items():
        try:
            validate_sha(revision)
        except SyncError as error:
            raise SyncError(f"{path}: {error}") from error
    return revisions


def check(root: Path) -> int:
    revisions = shared_revisions(root)
    unique_revisions = set(revisions.values())
    if len(unique_revisions) != 1:
        details = ", ".join(f"{path}={revision}" for path, revision in revisions.items())
        print(f"[sync-strata] drift: {details}", file=sys.stderr)
        return 1
    print(f"[sync-strata] ok: {next(iter(unique_revisions))}")
    return 0


def atomic_write(path: Path, content: bytes, mode: int) -> None:
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="wb", dir=path.parent, prefix=f".{path.name}.", delete=False
        ) as temporary:
            temporary.write(content)
            temporary_path = Path(temporary.name)
        os.chmod(temporary_path, mode)
        os.replace(temporary_path, path)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()


def transaction(
    updates: dict[Path, bytes],
    action: Callable[[], None] | None = None,
) -> None:
    originals = {
        path: (path.read_bytes(), path.stat().st_mode & 0o777) for path in updates
    }
    try:
        for path, content in updates.items():
            atomic_write(path, content, originals[path][1])
        if action is not None:
            action()
    except Exception:
        for path, (content, mode) in originals.items():
            atomic_write(path, content, mode)
        raise


def resolve_latest() -> str:
    try:
        output = subprocess.run(
            [
                "git",
                "ls-remote",
                "https://github.com/LeePepe/shared-design-system.git",
                "refs/heads/main",
            ],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError) as error:
        raise SyncError(f"unable to resolve shared-design-system main: {error}") from error
    match = re.fullmatch(r"([0-9a-f]{40})\s+refs/heads/main", output)
    if match is None:
        raise SyncError("shared-design-system main did not return a valid SHA")
    return match.group(1)


def resolve_package(root: Path) -> None:
    try:
        subprocess.run(
            ["swift", "package", "--package-path", "app", "resolve"],
            cwd=root,
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        details = getattr(error, "stderr", "") or str(error)
        raise SyncError(f"swift package resolve failed: {details.strip()}") from error


def sync(root: Path, sha: str, skip_resolve: bool) -> dict[str, str]:
    sha = validate_sha(sha)
    metadata_path = root / ".github/repo-contract.json"
    package_path = root / "app/Package.swift"
    resolved_path = root / "app/Package.resolved"
    guide_path = root / "docs/repository-guide.md"

    metadata = read_metadata(metadata_path)
    previous_sha = metadata["dependencies"]["shared-design-system"]["version"]
    package_text = package_path.read_text(encoding="utf-8")
    resolved_text = resolved_path.read_text(encoding="utf-8")
    guide_text = guide_path.read_text(encoding="utf-8") if guide_path.exists() else None

    metadata["dependencies"]["shared-design-system"]["version"] = sha
    metadata["dependencies"]["shared-design-system"][
        "ai"
    ] = f"https://github.com/LeePepe/shared-design-system/tree/{sha}/ai/"
    updated_metadata = (json.dumps(metadata, indent=2) + "\n").encode("utf-8")
    updated_package = replace_package_revision(package_text, sha).encode("utf-8")
    updated_resolved = replace_resolved_revision(resolved_text, sha).encode("utf-8")
    updates = {
        metadata_path: updated_metadata,
        package_path: updated_package,
        resolved_path: updated_resolved,
    }
    if guide_text is not None:
        updates[guide_path] = update_guide_revision(guide_text, sha).encode("utf-8")

    if all(path.read_bytes() == content for path, content in updates.items()):
        return {"status": "noop", "previous_sha": previous_sha, "new_sha": sha}

    transaction(
        updates,
        None if skip_resolve else lambda: resolve_package(root),
    )
    return {"status": "updated", "previous_sha": previous_sha, "new_sha": sha}


def local_override(root: Path, path: str) -> int:
    override_path = Path(path).expanduser().resolve()
    if not override_path.is_dir():
        raise SyncError(f"local override path is not a directory: {override_path}")
    try:
        subprocess.run(
            [
                "swift",
                "package",
                "--package-path",
                "app",
                "edit",
                "shared-design-system",
                "--path",
                str(override_path),
            ],
            cwd=root,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        raise SyncError(f"swift package edit failed: {error}") from error
    return 0


def reset_override(root: Path) -> int:
    try:
        subprocess.run(
            ["swift", "package", "--package-path", "app", "unedit", "shared-design-system"],
            cwd=root,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        raise SyncError(f"swift package unedit failed: {error}") from error
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--sha")
    modes.add_argument("--latest", action="store_true")
    modes.add_argument("--check", action="store_true")
    modes.add_argument("--local-override", metavar="PATH")
    modes.add_argument("--reset-override", action="store_true")
    parser.add_argument("--skip-resolve", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = repository_root()
    if args.skip_resolve and not (args.sha or args.latest):
        raise SyncError("--skip-resolve requires --sha or --latest")
    if args.check:
        return check(root)
    if args.local_override:
        return local_override(root, args.local_override)
    if args.reset_override:
        return reset_override(root)
    sha = validate_sha(args.sha) if args.sha else resolve_latest()
    summary = sync(root, sha, args.skip_resolve)
    print(json.dumps(summary, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, SyncError) as error:
        print(f"[sync-strata] error: {error}", file=sys.stderr)
        raise SystemExit(2) from error
