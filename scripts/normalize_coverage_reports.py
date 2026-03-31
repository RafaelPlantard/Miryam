#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path, PurePosixPath
import xml.etree.ElementTree as ET


IGNORED_FRAGMENTS = (
    "/Tests/",
    "/.build/",
    ".derived/",
    "/Snapshots/__Snapshots__/",
)


def to_relative(path_text: str, workspace: Path) -> str | None:
    normalized = path_text.replace("\\", "/")
    path = Path(normalized)
    if path.is_absolute():
        try:
            relative = path.relative_to(workspace)
        except ValueError:
            return None
    else:
        relative = Path(normalized.lstrip("./"))

    relative_text = PurePosixPath(relative).as_posix()
    return relative_text or None


def should_ignore(relative_path: str) -> bool:
    normalized = f"/{relative_path}"
    return any(fragment in normalized for fragment in IGNORED_FRAGMENTS)


def normalize_xml(path: Path, workspace: Path) -> None:
    tree = ET.parse(path)
    root = tree.getroot()

    for classes in root.findall(".//classes"):
        for class_element in list(classes):
            filename = class_element.attrib.get("filename")
            if not filename:
                continue

            relative = to_relative(filename, workspace)
            if relative is None or should_ignore(relative):
                classes.remove(class_element)
                continue

            class_element.set("filename", relative)

    sources = root.find("sources")
    if sources is not None:
        for source in list(sources):
            sources.remove(source)
        ET.SubElement(sources, "source").text = "."

    tree.write(path, encoding="utf-8", xml_declaration=True)


def normalize_json(path: Path, workspace: Path) -> None:
    payload = json.loads(path.read_text())

    for dataset in payload.get("data", []):
        kept_files = []
        kept_names: set[str] = set()

        for file_entry in dataset.get("files", []):
            filename = file_entry.get("filename")
            if not filename:
                continue

            relative = to_relative(filename, workspace)
            if relative is None or should_ignore(relative):
                continue

            file_entry["filename"] = relative
            kept_files.append(file_entry)
            kept_names.add(relative)

        dataset["files"] = kept_files

        kept_functions = []
        for function in dataset.get("functions", []):
            filenames = []
            for filename in function.get("filenames", []):
                relative = to_relative(filename, workspace)
                if relative is None or should_ignore(relative):
                    continue
                filenames.append(relative)

            if not filenames:
                continue

            function["filenames"] = filenames
            kept_functions.append(function)

        dataset["functions"] = kept_functions

    path.write_text(json.dumps(payload, separators=(",", ":")))


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize coverage report paths for Codecov")
    parser.add_argument("coverage_dir", type=Path)
    parser.add_argument("--workspace", type=Path, default=Path.cwd())
    args = parser.parse_args()

    coverage_dir = args.coverage_dir
    workspace = args.workspace.resolve()

    if not coverage_dir.exists():
        raise SystemExit(0)

    for path in coverage_dir.rglob("*"):
        if path.suffix == ".xml":
            normalize_xml(path, workspace)
        elif path.suffix == ".json":
            normalize_json(path, workspace)


if __name__ == "__main__":
    main()
