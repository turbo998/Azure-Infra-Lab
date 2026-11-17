#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from collections import Counter
from pathlib import Path


def max_suffix_repeat(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    in_code = False
    suffixes: list[str] = []
    for raw in text.splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped.startswith("```"):
            in_code = not in_code
            continue
        if in_code or not stripped:
            continue
        if stripped.startswith("|") and stripped.endswith("|"):
            continue
        if len(stripped) < 30:
            continue
        normalized = re.sub(r"^[-*0-9A-Za-z.)\s：:—–-]+", "", stripped)
        if not normalized:
            continue
        suffixes.append(normalized[-48:])
    if not suffixes:
        return 0
    return max(Counter(suffixes).values())


def section_order_ok(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\)", text, flags=re.M)]
    return nums == list(range(1, 16))


def main() -> None:
    parser = argparse.ArgumentParser(description="Strict suffix-repeat gate")
    parser.add_argument("files", nargs="+", type=Path)
    args = parser.parse_args()

    failed = False
    for p in args.files:
        mx = max_suffix_repeat(p)
        order_ok = section_order_ok(p)
        print(f"{p}|section_order={order_ok}|max_suffix_repeat={mx}")
        if not order_ok or mx != 1:
            failed = True

    if failed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
