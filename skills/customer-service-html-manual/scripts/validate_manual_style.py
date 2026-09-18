#!/usr/bin/env python3
"""驗證客服手冊是否維持 canonical template 的視覺樣式。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


STYLE_PATTERN = re.compile(r"<style>(.*?)</style>", re.DOTALL)
REQUIRED_MARKERS = (
    'lang="zh-Hant-TW"',
    'class="layout"',
    'class="sidebar"',
    "<main>",
    'class="hero"',
    'class="step"',
    "<figure>",
    "<details>",
    "@media (max-width: 980px)",
    "@media print",
    "#f73939",
)


def extract_style(html: str, path: Path) -> str:
    matches = STYLE_PATTERN.findall(html)
    if len(matches) != 1:
        raise ValueError(f"{path} 必須且只能包含一個 <style> 區塊")
    return matches[0]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manual", type=Path, help="要驗證的客服手冊 HTML")
    args = parser.parse_args()

    template = Path(__file__).resolve().parent.parent / "assets" / "manual-template.html"
    manual_html = args.manual.read_text(encoding="utf-8")
    template_html = template.read_text(encoding="utf-8")

    errors: list[str] = []
    try:
        if extract_style(manual_html, args.manual) != extract_style(template_html, template):
            errors.append("<style> 與 canonical template 不一致")
    except ValueError as error:
        errors.append(str(error))

    for marker in REQUIRED_MARKERS:
        if marker not in manual_html:
            errors.append(f"缺少固定版型標記：{marker}")

    if re.search(r"\sstyle\s*=", manual_html, re.IGNORECASE):
        errors.append("不得使用 inline style")
    if re.search(r"<link\b[^>]*rel=[\"']stylesheet[\"']", manual_html, re.IGNORECASE):
        errors.append("不得載入外部 stylesheet")

    if errors:
        print("樣式驗證失敗：", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"樣式驗證通過：{args.manual}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
