# token-diet-foundation-001 — Scrivere `scripts/measure-tokens.py` con misura e delta

**Status**: ✅ finalized
**Origin**: flow-run attended
**Context-root**: docs/features/token-diet-foundation/
**Feature**: token-diet-foundation

---

## Vincoli risolti

### Stack e runtime
- Python 3 stdlib only (re, glob, os, sys, json, argparse). Zero dipendenze esterne.
- Repo root risolto via `os.path.dirname(os.path.dirname(os.path.abspath(__file__)))` — path-agnostico.

### Pattern di misura
- Ratio char/token: IT ~3.4 char/tok, EN ~4.0 char/tok (proxy comparativo, identico a fase d'analisi).
- Lingua rilevata con euristica su segnali lessicali italiani (≥3 hit → IT, altrimenti EN) — separata per description e body.
- Stima: `max(1, round(len(text) / ratio))`.

### Parsing frontmatter
- Delimitatori `---` standard; supporta tre forme di `description`:
  - single-line: `description: valore`
  - folded `>`: righe indentate ≥2 spazi, giunte con spazio
  - folded `>-`: identico (nessuna trailing newline → irrilevante per la misura)
- Body = tutto dopo il secondo `---` (stripato).
- File senza frontmatter: description vuota, body = intero contenuto.

### Nomenclatura metriche
- **always-on**: somma token `description` (caricata ad ogni invocazione della skill/agent).
- **hot-path**: somma token `body` (caricato nel contesto solo quando la skill è attivata).

### Formato baseline
```
{
  "version": 1,
  "method": "char/token proxy: IT=3.4, EN=4.0",
  "totals": { "tokens_desc": <int>, "tokens_body": <int> },
  "artifacts": {
    "<rel_path>": {
      "tokens_desc": <int>, "tokens_body": <int>,
      "chars_desc": <int>, "chars_body": <int>,
      "lang_desc": "it|en", "lang_body": "it|en"
    }
  }
}
```
(shape, non implementazione finale)

### Interfacce CLI
- `python3 scripts/measure-tokens.py` → tabella + totali
- `python3 scripts/measure-tokens.py --save` → tabella + salva baseline in `scripts/token-baseline.json`
- `python3 scripts/measure-tokens.py --delta` → tabella con delta vs baseline esistente
- `--baseline <path>` → override path baseline (default: `scripts/token-baseline.json`)

---

## File impattati

- `scripts/measure-tokens.py` [new]
- `scripts/token-baseline.json` [new]

---

## Shape reale

```python
# Parsing frontmatter (forma sintetica)
def parse_frontmatter_and_body(content: str) -> tuple[str, str]:
    """Ritorna (description, body). Gestisce single-line e folded (>/>-)."""
    lines = content.splitlines()
    # individua fm_start, fm_end via delimitatori ---
    # estrae fm_lines e body_lines
    description = _extract_description(fm_lines)
    body = "\n".join(body_lines).strip()
    return description, body

def _extract_description(fm_lines):
    # match r'^description:\s*(>-?|.*)'
    # se value in (">", ">-"): raccoglie righe indentate ≥2 spazi, join con spazio
    # altrimenti: ritorna value single-line

# Misura
def estimate_tokens(text, lang=None) -> int:
    ratio = RATIO_IT if lang == "it" else RATIO_EN
    return max(1, round(len(text) / ratio))

# Scoperta artefatti
def discover_artifacts(repo_root) -> list[dict]:
    # glob skills/*/SKILL.md + agents/*.md
    # ritorna [{ path, rel_path, artifact_type }]

# Output tabella: raggruppato per [SKILLS] / [AGENTS]
# Con --delta: colonne delta "(+N)" accanto ai token
# Totale aggregato + Delta % se baseline presente

# Baseline: JSON strutturato con version/method/totals/artifacts
# save_baseline / load_baseline via json stdlib
```
(shape, non implementazione finale)

---

## Deviazioni

Nessuna deviazione rispetto al piano del tasks-file. Il path `scripts/token-baseline.json` era indicato come esempio ("es.") nel tasks-file — confermato come path definitivo.

---

*Generato: 2026-06-03 | Implementato da: flow-run attended (solo)*
