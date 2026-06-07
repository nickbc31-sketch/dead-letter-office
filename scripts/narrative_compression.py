#!/usr/bin/env python3
"""Narrative compression pass — cases, levels, stats for audit."""

import json
import re
from pathlib import Path
from typing import Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
CASES_DIR = ROOT / "DeadLetterOffice/Data/Cases"
LEVELS_DIR = ROOT / "DeadLetterOffice/Data/Levels"

NARRATIVE_KEYS = frozenset({
    "bodyText", "suspicionNote", "displayText", "description",
    "cartridgeData", "messageText", "text", "footerText", "maraObservation",
})

CATEGORY_HINTS = [
    (r"14:\d+|15:\d+|\d{2}:\d{2}|timing|filed|certif|registered at", "Check timing against related records."),
    (r"see .*death|date of death|deceased|pmca status|death registration", "Check death record status."),
    (r"see .*transit|incident|derail|train", "Check transit status."),
    (r"see .*housing|relocat|dwell|occupancy|utility|key access|gate", "Check housing status."),
    (r"authoris|pmca directorate|ministry|issuer|authority|standard authority", "Check issuing authority."),
    (r"trigger|phrase|class [dsc]|censor|communicat|'they marked", "Check communication triggers."),
    (r"routing|relay|buffer|orphan|tag|rerout", "Check routing records."),
    (r"identity|citizen id|personnel|roster|not found|registry cross", "Check identity records."),
    (r"location|sector|block|unit|coordinate|worksit", "Check location records."),
    (r"soulprint|biometric|active.*deceased|terminat|living", "Check death record vs current status."),
    (r"see .*seal|corporate|injunction|helix", "Check corporate authority records."),
    (r"see .*recipient|see .*citizen|see .*file", "Compare flagged fields across documents."),
    (r"see ", "Compare flagged fields across documents."),
]


def narrative_len(obj) -> int:
    total = 0
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in NARRATIVE_KEYS and isinstance(v, str):
                total += len(v)
            elif k == "fields" and isinstance(v, list):
                for f in v:
                    if isinstance(f, dict) and isinstance(f.get("suspicionNote"), str):
                        total += len(f["suspicionNote"])
            else:
                total += narrative_len(v)
    elif isinstance(obj, list):
        for item in obj:
            total += narrative_len(item)
    return total


def compress_suspicion(note: Optional[str]) -> Optional[str]:
    if not note:
        return note
    for pattern, hint in CATEGORY_HINTS:
        if re.search(pattern, note, re.I):
            return hint
    if len(note) > 55:
        return "Compare flagged fields across documents."
    return note


def compress_contradiction(desc: str, field_a: str, field_b: str) -> str:
    combined = f"{field_a} {field_b} {desc}".lower()
    rules = [
        (r"death|deceased|14:|15:|transit|incident", "Check death record timing against transit status."),
        (r"housing|occupancy|relocat|dwell", "Check housing status against death record."),
        (r"routing|relay|buffer|orphan", "Check routing records against desk logs."),
        (r"identity|personnel|not found|citizen", "Check identity records across systems."),
        (r"communicat|phrase|censor|trigger", "Check communication triggers against policy."),
        (r"active.*deceased|living|gate|utility", "Check death record against current status."),
        (r"location|sector|coordinate|worksit", "Check location records for conflicts."),
        (r"corporate|seal|injunction|helix", "Check corporate authority against incident record."),
        (r"memory|deletion|trial|biometric", "Check termination record against live readings."),
    ]
    for pattern, hint in rules:
        if re.search(pattern, combined):
            return hint
    if len(desc) > 70 or re.search(
        r"before|after|not logged|confirms|preceded|while|because|therefore|the recipient has",
        desc,
        re.I,
    ):
        return "Compare flagged record fields."
    return desc


def compress_body_text(text: str, fields: list) -> str:
    if not text:
        return text
    if fields and len(fields) >= 3:
        return ""
    sentence = re.split(r"[.!?]\s+", text.strip())[0].strip()
    if len(sentence) > 85:
        sentence = sentence[:82] + "..."
    return sentence if sentence.endswith(".") else sentence + "."


def infer_mara_observation(text: str, terminal_id: Optional[str] = None) -> Optional[str]:
    lower = text.lower()
    overrides = {
        "terminal_01": "Checkpoint codes rotate with case IDs. Desk won't show the routing buffer.",
        "terminal_02": "Forty-seven messages queued — someone's routing off the official channel.",
        "relay_console_01": "Credential locker needs console sign-out before we leave.",
    }
    if terminal_id and terminal_id in overrides:
        return overrides[terminal_id]
    if "manual override" in lower or "rerout" in lower:
        return "Someone changed these routes after they were approved."
    if "scheduled deletion" in lower or "deletion:" in lower:
        return "They're scheduling deletions before clerks see the buffer."
    if "not found" in lower and ("personnel" in lower or "registry" in lower):
        return "Credentials exist. No personnel file. Ghost identity."
    if "orphan" in lower or "unregistered sender" in lower:
        return "Desk terminals don't show this buffer."
    if "biometric active" in lower or "active 5 years" in lower:
        return "Still active on the subnet. Death record says otherwise."
    if "officially dead" in lower or "operating the train" in lower:
        return "Declared dead. Still logged in on the infrastructure."
    if "forgery" in lower or "forged" in lower:
        return "Signatures don't all match. Someone faked the petition."
    if "living-dead" in lower or "847" in lower:
        return "Hundreds listed living-dead beneath the sealed district."
    if "memory deletion" in lower and "not physical death" in lower:
        return "Erased from the system — not killed. Different kind of death."
    if "version a" in lower or "clerk chose" in lower:
        return "The clerk picked which truth the executive left behind."
    if "deferred transit" in lower or "forbidden" in lower:
        return "Messages held in limbo — not delivered, not destroyed."
    if "waveform" in lower or "coordinate" in lower:
        return "Coordinates hidden in the waveform. Map doesn't match death location."
    if "tier 3" in lower or "legacy edit" in lower:
        return "The wealthy buy edited afterlives. Service class gets trials."
    return None


def compress_terminal_text(text: str, terminal_id: Optional[str] = None) -> Tuple[str, Optional[str]]:
    if not text:
        return text, None
    lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
    skip_phrases = (
        "connect pda", "apply override", "see notebook", "see case",
        "you are standing", "proceed when", "authorised personnel only",
    )
    kept = []
    for line in lines:
        low = line.lower()
        if line.startswith("["):
            continue
        if any(p in low for p in skip_phrases):
            continue
        kept.append(line)
        if len(kept) >= 6:
            break
    result = "\n".join(kept) if kept else "\n".join(lines[:4])
    if len(result) > 280:
        result = "\n".join(result.split("\n")[:5])
    mara = infer_mara_observation(text, terminal_id)
    return result, mara


def compress_cartridge(text: str) -> str:
    if not text:
        return text
    lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
    poetic = [ln for ln in lines if not ln.startswith("[")]
    return "\n".join(poetic[:8])


def compress_env_text(text: str) -> str:
    if not text:
        return text
    first = text.split("\n")[0].strip()
    return first[:48] if len(first) > 48 else first


def process_case(case: dict) -> None:
    for doc in case.get("documents", []):
        fields = doc.get("fields", [])
        doc["bodyText"] = compress_body_text(doc.get("bodyText", ""), fields)
        for field in fields:
            if field.get("suspicionNote"):
                field["suspicionNote"] = compress_suspicion(field["suspicionNote"])
    for c in case.get("contradictions", []):
        c["description"] = compress_contradiction(
            c.get("description", ""), c.get("fieldA", ""), c.get("fieldB", "")
        )


def process_terminal_obj(obj: dict) -> None:
    if obj.get("displayText"):
        new_text, mara = compress_terminal_text(obj["displayText"], obj.get("id"))
        obj["displayText"] = new_text
        if mara and not obj.get("maraObservation"):
            obj["maraObservation"] = mara


def process_level(level: dict) -> None:
    for slot in level.get("encounterSequence") or []:
        if slot.get("module") == "terminal_investigation" and slot.get("terminal"):
            process_terminal_obj(slot["terminal"])
        if slot.get("module") == "environmental_story" and slot.get("environmental"):
            env = slot["environmental"]
            if env.get("text"):
                env["text"] = compress_env_text(env["text"])
    for inter in level.get("interactables") or []:
        if inter.get("type") == "terminal" and inter.get("displayText"):
            process_terminal_obj(inter)
        elif inter.get("displayText"):
            inter["displayText"] = "\n".join(inter["displayText"].split("\n")[:3])
        if inter.get("cartridgeData"):
            inter["cartridgeData"] = compress_cartridge(inter["cartridgeData"])
    for node in level.get("environmentalTextNodes") or []:
        if node.get("text"):
            node["text"] = compress_env_text(node["text"])


def main():
    stats = {"cases": {}, "levels": {}, "totals": {}}

    case_before = case_after = 0
    for path in sorted(CASES_DIR.glob("cases_ch*.json")):
        data = json.loads(path.read_text())
        before = narrative_len(data)
        for case in data:
            process_case(case)
        after = narrative_len(data)
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
        stats["cases"][path.name] = {"before": before, "after": after}
        case_before += before
        case_after += after

    level_before = level_after = 0
    for path in sorted(LEVELS_DIR.glob("level_*.json")):
        data = json.loads(path.read_text())
        before = narrative_len(data)
        process_level(data)
        after = narrative_len(data)
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
        stats["levels"][path.name] = {"before": before, "after": after}
        level_before += before
        level_after += after

    def pct(b, a):
        return round((1 - a / b) * 100, 1) if b else 0

    stats["totals"] = {
        "cases_before": case_before,
        "cases_after": case_after,
        "cases_reduction_pct": pct(case_before, case_after),
        "levels_before": level_before,
        "levels_after": level_after,
        "levels_reduction_pct": pct(level_before, level_after),
    }
    out = ROOT / "scripts/narrative_compression_stats.json"
    out.write_text(json.dumps(stats, indent=2))
    print(json.dumps(stats["totals"], indent=2))


if __name__ == "__main__":
    main()
