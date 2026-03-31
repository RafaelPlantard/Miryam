#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path
import xml.etree.ElementTree as ET


CoverageMap = dict[str, dict[int, bool]]


def merge_line(coverage: CoverageMap, filename: str, line_number: int, covered: bool) -> None:
    file_coverage = coverage.setdefault(filename, {})
    file_coverage[line_number] = file_coverage.get(line_number, False) or covered


def parse_cobertura(path: Path, coverage: CoverageMap) -> None:
    root = ET.parse(path).getroot()
    for class_element in root.findall(".//class"):
        filename = class_element.attrib.get("filename")
        if not filename:
            continue
        for line_element in class_element.findall("./lines/line"):
            number = line_element.attrib.get("number")
            hits = line_element.attrib.get("hits")
            if not number or hits is None:
                continue
            merge_line(coverage, filename, int(number), int(hits) > 0)


def parse_lcov(path: Path, coverage: CoverageMap) -> None:
    current_file: str | None = None
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if line.startswith("SF:"):
            current_file = line[3:]
        elif line.startswith("DA:") and current_file is not None:
            number, hits = line[3:].split(",", 1)
            merge_line(coverage, current_file, int(number), int(hits) > 0)
        elif line == "end_of_record":
            current_file = None


def badge_color(percent: float) -> str:
    if percent >= 90:
        return "brightgreen"
    if percent >= 80:
        return "green"
    if percent >= 70:
        return "yellowgreen"
    if percent >= 60:
        return "yellow"
    if percent >= 50:
        return "orange"
    return "red"


def build_badge_payload(root: Path) -> dict[str, object]:
    coverage: CoverageMap = {}

    for path in root.rglob("*"):
      if path.suffix == ".xml":
        parse_cobertura(path, coverage)
      elif path.suffix == ".lcov":
        parse_lcov(path, coverage)

    tracked = sum(len(lines) for lines in coverage.values())
    covered = sum(1 for lines in coverage.values() for is_covered in lines.values() if is_covered)
    percent = 0.0 if tracked == 0 else (covered / tracked) * 100

    return {
        "schemaVersion": 1,
        "label": "codecov",
        "message": f"{percent:.2f}%",
        "color": badge_color(percent),
        "covered": covered,
        "tracked": tracked,
    }


def main() -> None:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("artifacts")
    payload = build_badge_payload(root)
    json.dump(payload, sys.stdout)


if __name__ == "__main__":
    main()
