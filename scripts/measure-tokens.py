#!/usr/bin/env python3
"""
measure-tokens.py — misura stima token per skills/*/SKILL.md e agents/*.md.

Uso:
  python3 scripts/measure-tokens.py            # misura + stampa tabella
  python3 scripts/measure-tokens.py --save     # misura + salva baseline
  python3 scripts/measure-tokens.py --delta    # misura + confronta con baseline

Output:
  Tabella per-artefatto: artefatto | description (always-on) | body (hot-path)
  Totali: always-on (sum description) + hot-path (sum body)
  Con --delta: delta token vs baseline per artefatto e aggregato

Nota: le stime token sono proxy comparativi (char/token ratio).
  IT: ~3.4 char/token  |  EN: ~4.0 char/token
  Lo stesso metodo deve essere usato before/after per delta affidabili.
"""

import os
import re
import sys
import json
import glob
import argparse
from typing import Optional

# ---------------------------------------------------------------------------
# Costanti
# ---------------------------------------------------------------------------

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASELINE_PATH = os.path.join(REPO_ROOT, "scripts", "token-baseline.json")

# Ratio char/token (proxy comparativo, non tokenizer reale)
RATIO_IT = 3.4
RATIO_EN = 4.0

# Euristica lingua: se il testo contiene queste parole (case-insensitive) → IT
ITALIAN_SIGNALS = [
    "quando", "oppure", "invece", "tramite", "gestione", "nella", "dello",
    "della", "degli", "delle", "viene", "sono", "per", "con", "che",
    "non", "una", "uno", "anche", "solo", "ogni",
]


# ---------------------------------------------------------------------------
# Parsing frontmatter + body
# ---------------------------------------------------------------------------

def detect_language(text: str) -> str:
    """Ritorna 'it' o 'en' in base a segnali euristici."""
    lower = text.lower()
    hits = sum(1 for w in ITALIAN_SIGNALS if re.search(r'\b' + re.escape(w) + r'\b', lower))
    return "it" if hits >= 3 else "en"


def estimate_tokens(text: str, lang: Optional[str] = None) -> int:
    """Stima token da testo con ratio char/token."""
    if not text:
        return 0
    if lang is None:
        lang = detect_language(text)
    ratio = RATIO_IT if lang == "it" else RATIO_EN
    return max(1, round(len(text) / ratio))


def parse_frontmatter_and_body(content: str) -> tuple[str, str]:
    """
    Ritorna (description, body) da un file con frontmatter YAML.

    Gestisce:
    - description single-line:  description: valore
    - description folded (>):   description: >
                                  riga1
                                  riga2
    - description folded (>-):  description: >-
                                  riga1
                                  riga2
    """
    # Individua i delimitatori ---
    lines = content.splitlines()
    fm_start = -1
    fm_end = -1
    for i, line in enumerate(lines):
        if line.strip() == "---":
            if fm_start == -1:
                fm_start = i
            else:
                fm_end = i
                break

    if fm_start == -1 or fm_end == -1:
        # Nessun frontmatter: tutto il contenuto è body
        return "", content.strip()

    fm_lines = lines[fm_start + 1:fm_end]
    body_lines = lines[fm_end + 1:]
    body = "\n".join(body_lines).strip()

    # Estrai description dal frontmatter
    description = _extract_description(fm_lines)
    return description, body


def _extract_description(fm_lines: list[str]) -> str:
    """Estrae il campo description dal frontmatter (lista di righe)."""
    desc_idx = -1
    folded = False

    for i, line in enumerate(fm_lines):
        m = re.match(r'^description:\s*(>-?|.*)', line)
        if m:
            value = m.group(1).strip()
            if value in (">", ">-"):
                # Folded: le righe indentate seguenti sono il valore
                folded = True
                desc_idx = i
            elif value:
                # Single-line
                return value
            else:
                # description: <empty> — tratta come folded
                folded = True
                desc_idx = i
            break

    if folded and desc_idx >= 0:
        # Raccoglie righe indentate (con almeno 2 spazi) fino alla prossima chiave
        parts = []
        for line in fm_lines[desc_idx + 1:]:
            if re.match(r'^\s{2,}', line):
                parts.append(line.strip())
            elif line.strip() == "" and parts:
                # Riga vuota all'interno del blocco folded
                parts.append("")
            else:
                break
        # Folded YAML: unisce le righe con spazio (comportamento >/-)
        text = " ".join(p for p in parts if p)
        return text

    return ""


# ---------------------------------------------------------------------------
# Scoperta artefatti
# ---------------------------------------------------------------------------

def discover_artifacts(repo_root: str) -> list[dict]:
    """
    Ritorna lista di { path, rel_path, artifact_type }
    per skills/*/SKILL.md e agents/*.md
    """
    artifacts = []

    # skills/*/SKILL.md
    pattern_skills = os.path.join(repo_root, "skills", "*", "SKILL.md")
    for path in sorted(glob.glob(pattern_skills)):
        rel = os.path.relpath(path, repo_root)
        artifacts.append({"path": path, "rel_path": rel, "artifact_type": "skill"})

    # agents/*.md
    pattern_agents = os.path.join(repo_root, "agents", "*.md")
    for path in sorted(glob.glob(pattern_agents)):
        rel = os.path.relpath(path, repo_root)
        artifacts.append({"path": path, "rel_path": rel, "artifact_type": "agent"})

    return artifacts


# ---------------------------------------------------------------------------
# Misura
# ---------------------------------------------------------------------------

def measure_artifact(artifact: dict) -> dict:
    """Misura token description + body per un artefatto."""
    path = artifact["path"]
    with open(path, encoding="utf-8") as f:
        content = f.read()

    description, body = parse_frontmatter_and_body(content)

    lang_desc = detect_language(description) if description else "en"
    lang_body = detect_language(body) if body else "en"

    tokens_desc = estimate_tokens(description, lang_desc)
    tokens_body = estimate_tokens(body, lang_body)

    return {
        "rel_path": artifact["rel_path"],
        "artifact_type": artifact["artifact_type"],
        "lang_desc": lang_desc,
        "lang_body": lang_body,
        "chars_desc": len(description),
        "chars_body": len(body),
        "tokens_desc": tokens_desc,
        "tokens_body": tokens_body,
    }


def measure_all(repo_root: str) -> list[dict]:
    artifacts = discover_artifacts(repo_root)
    return [measure_artifact(a) for a in artifacts]


# ---------------------------------------------------------------------------
# Output tabella
# ---------------------------------------------------------------------------

COL_PATH = 42
COL_NUM = 8


def _row(label: str, tokens_desc: int, tokens_body: int, delta_desc: Optional[int] = None,
         delta_body: Optional[int] = None) -> str:
    def fmt_delta(d: Optional[int]) -> str:
        if d is None:
            return ""
        sign = "+" if d >= 0 else ""
        return f" ({sign}{d})"

    d_desc = f"{tokens_desc:>{COL_NUM - 2}}{fmt_delta(delta_desc)}"
    d_body = f"{tokens_body:>{COL_NUM - 2}}{fmt_delta(delta_body)}"
    return f"  {label:<{COL_PATH}}  {d_desc:<14}  {d_body:<14}"


def print_table(results: list[dict], baseline: Optional[dict] = None) -> None:
    has_delta = baseline is not None

    header_extra = "  (delta vs baseline)" if has_delta else ""
    print(f"\n  {'Artefatto':<{COL_PATH}}  {'desc (always-on)':>14}  {'body (hot-path)':>14}{header_extra}")
    print("  " + "-" * (COL_PATH + 36 + (22 if has_delta else 0)))

    total_desc = 0
    total_body = 0
    total_delta_desc = 0
    total_delta_body = 0

    # Raggruppa per tipo
    for artifact_type, label in [("skill", "SKILLS"), ("agent", "AGENTS")]:
        group = [r for r in results if r["artifact_type"] == artifact_type]
        if not group:
            continue
        print(f"\n  [{label}]")
        for r in group:
            delta_desc = None
            delta_body = None
            if has_delta and r["rel_path"] in baseline["artifacts"]:
                b = baseline["artifacts"][r["rel_path"]]
                delta_desc = r["tokens_desc"] - b["tokens_desc"]
                delta_body = r["tokens_body"] - b["tokens_body"]
                total_delta_desc += delta_desc
                total_delta_body += delta_body
            print(_row(r["rel_path"], r["tokens_desc"], r["tokens_body"], delta_desc, delta_body))
            total_desc += r["tokens_desc"]
            total_body += r["tokens_body"]

    print("\n  " + "=" * (COL_PATH + 36 + (22 if has_delta else 0)))
    delta_d = total_delta_desc if has_delta else None
    delta_b = total_delta_body if has_delta else None
    print(_row("TOTALE (always-on | hot-path)", total_desc, total_body, delta_d, delta_b))

    if has_delta:
        pct_desc = (total_delta_desc / baseline["totals"]["tokens_desc"] * 100) if baseline["totals"]["tokens_desc"] else 0
        pct_body = (total_delta_body / baseline["totals"]["tokens_body"] * 100) if baseline["totals"]["tokens_body"] else 0
        sign_d = "+" if total_delta_desc >= 0 else ""
        sign_b = "+" if total_delta_body >= 0 else ""
        print(f"\n  Delta %  always-on: {sign_d}{pct_desc:.1f}%   hot-path: {sign_b}{pct_body:.1f}%")

    print(f"\n  Nota: stime proxy (IT ~{RATIO_IT} char/tok, EN ~{RATIO_EN} char/tok). Delta comparativi affidabili.\n")


# ---------------------------------------------------------------------------
# Baseline I/O
# ---------------------------------------------------------------------------

def load_baseline(path: str) -> Optional[dict]:
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_baseline(results: list[dict], path: str) -> None:
    artifacts_map = {r["rel_path"]: {
        "tokens_desc": r["tokens_desc"],
        "tokens_body": r["tokens_body"],
        "chars_desc": r["chars_desc"],
        "chars_body": r["chars_body"],
        "lang_desc": r["lang_desc"],
        "lang_body": r["lang_body"],
    } for r in results}

    totals = {
        "tokens_desc": sum(r["tokens_desc"] for r in results),
        "tokens_body": sum(r["tokens_body"] for r in results),
    }

    data = {
        "version": 1,
        "method": f"char/token proxy: IT={RATIO_IT}, EN={RATIO_EN}",
        "totals": totals,
        "artifacts": artifacts_map,
    }

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"  Baseline salvata in: {os.path.relpath(path, REPO_ROOT)}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Stima token per skill/agent di otto (proxy comparativo)."
    )
    parser.add_argument(
        "--save", action="store_true",
        help="Salva la misurazione corrente come baseline in scripts/token-baseline.json"
    )
    parser.add_argument(
        "--delta", action="store_true",
        help="Confronta con la baseline esistente e mostra i delta"
    )
    parser.add_argument(
        "--baseline", default=BASELINE_PATH,
        help=f"Path baseline JSON (default: {os.path.relpath(BASELINE_PATH, REPO_ROOT)})"
    )
    args = parser.parse_args()

    results = measure_all(REPO_ROOT)

    if not results:
        print("Nessun artefatto trovato. Verifica di essere nella root del repo otto.", file=sys.stderr)
        sys.exit(1)

    baseline = None
    if args.delta:
        baseline = load_baseline(args.baseline)
        if baseline is None:
            print(f"  Baseline non trovata in {args.baseline}. Esegui prima con --save.", file=sys.stderr)
            sys.exit(1)

    print_table(results, baseline)

    if args.save:
        save_baseline(results, args.baseline)


if __name__ == "__main__":
    main()
