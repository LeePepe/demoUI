#!/usr/bin/env python3
"""Decide whether the current main range requires a TestFlight upload."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RELEASE_TAG = "refs/tags/testflight/last-released"


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout


def changed_paths() -> tuple[list[str], bool]:
    tag_exists = subprocess.run(
        ["git", "rev-parse", "--verify", RELEASE_TAG],
        cwd=ROOT,
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    ).returncode == 0
    if not tag_exists:
        return [], True
    paths = git("diff", "--name-only", f"{RELEASE_TAG}..HEAD").splitlines()
    return paths, False


def affects_release(path: str) -> bool:
    return (
        path.startswith("app/")
        or path == "project.yml"
        or path.endswith("/project.yml")
        or path == ".github/repo-contract.json"
        or path.startswith("fastlane/")
        or path.startswith("config/")
    )


def check_contract() -> None:
    required = {
        "config/Signing.example.xcconfig": (
            "DEMOUI_BUNDLE_ID = com.example.demoui",
            "DEMOUI_TEAM_ID = ZZZZZZZZZZ",
        ),
        "fastlane/Appfile": (
            "DEMOUI_BUNDLE_ID",
            "DEMOUI_TEAM_ID",
        ),
        "fastlane/Fastfile": (
            "lane :beta",
            "xcodegen generate --spec app/project.yml --project app",
            "ASC_KEY_ID",
            "ASC_ISSUER_ID",
            "ASC_KEY_P8_BASE64",
            "build_app",
            "upload_to_testflight",
            "skip_waiting_for_build_processing: true",
        ),
        ".github/workflows/testflight.yml": (
            'workflows: ["ci"]',
            "47 6,18 * * *",
            "github.event.pull_request == null || github.event.pull_request.head.repo.full_name == github.repository",
            "ASC_KEY_ID",
            "ASC_ISSUER_ID",
            "ASC_KEY_P8_BASE64",
            "KEYCHAIN_PASSWORD",
            "DEMOUI_BUNDLE_ID",
            "DEMOUI_TEAM_ID",
            "refs/tags/testflight/last-released",
        ),
    }
    failures: list[str] = []
    for relative, snippets in required.items():
        path = ROOT / relative
        if not path.is_file():
            failures.append(f"missing {relative}")
            continue
        content = path.read_text(encoding="utf-8")
        for snippet in snippets:
            if snippet not in content:
                failures.append(f"{relative} is missing {snippet!r}")

    workflow = (ROOT / ".github/workflows/testflight.yml").read_text(
        encoding="utf-8"
    )
    normalized_workflow = re.sub(r"\s+", " ", workflow)
    if (
        "github.event.pull_request == null || github.event.pull_request.head.repo.full_name == github.repository"
        not in normalized_workflow
    ):
        failures.append("workflow fork guard is not present")

    if failures:
        raise RuntimeError("contract check failed:\n- " + "\n- ".join(failures))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--check-contract", action="store_true")
    args = parser.parse_args()

    try:
        if args.check_contract:
            check_contract()
            print(json.dumps({"contract": "ok"}))
        paths, missing_tag = changed_paths()
    except (OSError, RuntimeError) as error:
        print(str(error), file=sys.stderr)
        return 1

    release = args.force or missing_tag or any(affects_release(path) for path in paths)
    if args.force:
        reason = "force"
    elif missing_tag:
        reason = "missing-tag"
    elif any(affects_release(path) for path in paths):
        reason = "eligible"
    else:
        reason = "path-ineligible"

    print(f"release={'true' if release else 'false'}")
    if missing_tag:
        print("reason=missing testflight/last-released tag")
    elif args.force:
        print("reason=forced")
    else:
        matching = [path for path in paths if affects_release(path)]
        print("changed=" + (",".join(matching) if matching else "none"))
    print(json.dumps({"release": release, "reason": reason}))
    if args.dry_run:
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
