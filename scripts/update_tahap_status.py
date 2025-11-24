#!/usr/bin/env python3
"""Update the Tahap status badge based on progress.json."""

from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[1]
PROGRESS_FILE = ROOT / "progress.json"
README_FILE = ROOT / "README.md"


class ProgressError(RuntimeError):
  """Raised when the progress configuration is invalid."""


def _load_progress() -> dict:
  if not PROGRESS_FILE.exists():
    raise ProgressError(f"Missing {PROGRESS_FILE}")
  try:
    return json.loads(PROGRESS_FILE.read_text(encoding="utf-8"))
  except json.JSONDecodeError as exc:
    raise ProgressError(f"Invalid JSON in {PROGRESS_FILE}: {exc}") from exc


def _validate_stage(stage: dict) -> None:
  required_stage_keys = {"id", "label", "max_percent", "tasks"}
  missing = required_stage_keys - stage.keys()
  if missing:
    raise ProgressError(f"Stage {stage!r} missing keys: {sorted(missing)}")
  task_sum = sum(float(task["percent"]) for task in stage["tasks"])
  max_percent = float(stage["max_percent"])
  if not math.isclose(task_sum, max_percent, abs_tol=1e-6):
    raise ProgressError(
        f"Stage {stage['id']} task weights ({task_sum}) != max_percent ({max_percent})"
    )


def _compute_totals(data: dict) -> tuple[str, float]:
  total_progress = 0.0
  current_stage_label = data["stages"][-1]["label"]

  for stage in data["stages"]:
    _validate_stage(stage)
    completed = sum(
        float(task["percent"]) for task in stage["tasks"] if bool(task.get("done"))
    )
    total_progress += min(completed, float(stage["max_percent"]))
    if completed < stage["max_percent"]:
      current_stage_label = stage["label"]
      break

  total_progress = min(total_progress, 100.0)
  return current_stage_label, total_progress


def _update_readme(status_label: str) -> bool:
  if not README_FILE.exists():
    raise ProgressError("README.md not found")

  content = README_FILE.read_text(encoding="utf-8")
  badge_regex = re.compile(
      r"!\[Status\]\(https://img\.shields\.io/badge/Status-.*?for-the-badge\)",
      flags=re.IGNORECASE,
  )
  encoded_label = quote(status_label, safe="")
  new_badge = (
      "![Status](https://img.shields.io/badge/Status-"
      f"{encoded_label}-yellow?style=for-the-badge)"
  )

  if badge_regex.search(content):
    updated = badge_regex.sub(new_badge, content, count=1)
  else:
    raise ProgressError("Status badge not found in README.md")

  if updated == content:
    return False

  README_FILE.write_text(updated, encoding="utf-8", newline="\n")
  return True


def main() -> int:
  data = _load_progress()
  stage_label, progress_value = _compute_totals(data)
  status_label = f"TAHAP {stage_label} ({round(progress_value)}%)"

  changed = _update_readme(status_label)
  print(f"Updated badge to '{status_label}'. Changed README: {changed}")
  return 0


if __name__ == "__main__":
  try:
    raise SystemExit(main())
  except ProgressError as exc:
    print(f"Progress update failed: {exc}", file=sys.stderr)
    raise SystemExit(1) from exc
