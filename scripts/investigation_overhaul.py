#!/usr/bin/env python3
"""Investigation gameplay overhaul — categories, terminal compression, case trim."""

import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
CASES_DIR = ROOT / "DeadLetterOffice/Data/Cases"
LEVELS_DIR = ROOT / "DeadLetterOffice/Data/Levels"

DOC_TYPE_CATEGORY = {
    "death_certificate": "DEATH RECORD",
    "incident_report": "TRANSIT",
    "housing_relocation": "HOUSING",
    "citizen_record": "IDENTITY",
    "restricted_phrase_list": "COMMUNICATIONS",
    "corporate_notice": "EMPLOYMENT",
    "anomaly_warning": "IDENTITY",
    "routing_metadata": "COMMUNICATIONS",
    "family_registry": "IDENTITY",
    "employment_record": "EMPLOYMENT",
    "gate_access_log": "GATE ACCESS",
    "medical_record": "DEATH RECORD",
    "legal_filing": "COMMUNICATIONS",
    "archive_stub": "IDENTITY",
    "monitoring_notice": "COMMUNICATIONS",
    "transit_manifest": "TRANSIT",
    "seal_reference": "EMPLOYMENT",
}

TITLE_CATEGORY = {
    "TRANSIT": "TRANSIT",
    "DEATH": "DEATH RECORD",
    "HOUSING": "HOUSING",
    "RELOCATION": "HOUSING",
    "ROUTING": "COMMUNICATIONS",
    "GATE": "GATE ACCESS",
    "EMPLOYMENT": "EMPLOYMENT",
    "CITIZEN": "IDENTITY",
    "REGISTRY": "IDENTITY",
    "PHRASE": "COMMUNICATIONS",
    "MONITORING": "COMMUNICATIONS",
    "MANIFEST": "TRANSIT",
    "SEAL": "EMPLOYMENT",
    "INJUNCTION": "EMPLOYMENT",
    "TRIAL": "IDENTITY",
    "MEMORY": "IDENTITY",
}

FIELD_PRIORITY = {
    "DEATH RECORD": ["Date of Death", "Cause", "Citizen", "PMCA Status"],
    "TRANSIT": ["Report Filed", "Incident", "Accident", "Line"],
    "HOUSING": ["Occupancy Status", "Relocation Deadline", "Current Address", "Unit"],
    "IDENTITY": ["PMCA Status", "Citizen", "Citizen ID", "Registered Occupant"],
    "COMMUNICATIONS": ["Trigger phrases detected", "Routing tag", "Secondary tag", "Classification"],
    "EMPLOYMENT": ["Helix Meridian Seal", "Authorising Officer", "Employer", "Subject"],
    "GATE ACCESS": ["Last Gate Activity", "Last Key Access", "Access"],
}

ANOMALY_HOOKS = {
    "death record timing against transit": "Timestamps don't line up.",
    "housing status against death": "Someone's listed dead but still occupying.",
    "corporate authority": "That seal doesn't look current.",
    "routing records": "Routing tag doesn't match the registry.",
    "identity records": "Identity records conflict.",
    "communication triggers": "Message triggers don't match policy.",
    "death record against current": "Death record says gone. Activity says present.",
    "death record against message": "Death file is empty. Message isn't.",
    "location records": "Location data conflicts.",
    "termination record": "Terminated — but still active somewhere.",
    "Compare flagged": "Something in these records doesn't add up.",
}


def shorten_issuer(issuer: str) -> str:
    if not issuer:
        return issuer
    parts = issuer.split("—")
    return parts[0].strip() if parts else issuer[:40]


def category_for_doc(doc: Dict) -> Optional[str]:
    dtype = doc.get("type", "")
    if dtype in DOC_TYPE_CATEGORY:
        return DOC_TYPE_CATEGORY[dtype]
    title = doc.get("title", "").upper()
    for key, cat in TITLE_CATEGORY.items():
        if key in title:
            return cat
    return None


def fact_for_doc(doc: Dict, category: str) -> str:
    fields = doc.get("fields", [])
    priorities = FIELD_PRIORITY.get(category, [])
    for key in priorities:
        for f in fields:
            if f.get("key") == key and f.get("value"):
                val = f["value"]
                if len(val) > 42:
                    val = val[:39] + "..."
                return f"{key}: {val}"
    for f in fields:
        if f.get("isSuspicious") and f.get("value"):
            return f"{f['key']}: {f['value'][:40]}"
    if fields:
        f = fields[0]
        return f"{f['key']}: {f['value'][:40]}"
    return doc.get("title", "Record on file")[:40]


def build_categories(case: Dict) -> List[Dict]:
    seen = set()
    cats = []
    for doc in case.get("documents", []):
        cat = category_for_doc(doc)
        if not cat or cat in seen:
            continue
        seen.add(cat)
        cats.append({"category": cat, "fact": fact_for_doc(doc, cat)})
        if len(cats) >= 4:
            break
    return cats


def anomaly_hook(case: Dict) -> str:
    if case.get("contradictions"):
        desc = case["contradictions"][0].get("description", "").lower()
        for key, hook in ANOMALY_HOOKS.items():
            if key in desc:
                return hook
    return "Something in these records doesn't add up."


def trim_case(case: Dict) -> None:
    case["investigationCategories"] = build_categories(case)
    case["anomalyHook"] = anomaly_hook(case)
    for doc in case.get("documents", []):
        doc["bodyText"] = ""
        doc["issuer"] = shorten_issuer(doc.get("issuer", ""))
        doc["footerText"] = None
        keep = []
        for f in doc.get("fields", []):
            if f.get("isSuspicious") or len(keep) < 4:
                keep.append(f)
            elif len(keep) < 3:
                keep.append(f)
        if keep:
            doc["fields"] = keep[:5]


def compress_terminal(text: str) -> str:
    if not text:
        return text
    lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
    skip = ("connect pda", "apply override", "see notebook", "see case", "you are standing")
    kept = []
    for line in lines:
        if line.startswith("["):
            continue
        if any(s in line.lower() for s in skip):
            continue
        kept.append(line)
        if len(kept) >= 4:
            break
    return "\n".join(kept) if kept else "\n".join(lines[:3])


def process_level(level: Dict) -> None:
    for slot in level.get("encounterSequence") or []:
        if slot.get("module") == "terminal_investigation" and slot.get("terminal"):
            t = slot["terminal"]
            if t.get("displayText"):
                t["displayText"] = compress_terminal(t["displayText"])
        if slot.get("module") == "environmental_story" and slot.get("environmental"):
            env = slot["environmental"]
            if env.get("text"):
                env["text"] = env["text"].split("\n")[0][:44]
    for inter in level.get("interactables") or []:
        if inter.get("displayText") and inter.get("type") == "terminal":
            inter["displayText"] = compress_terminal(inter["displayText"])
        if inter.get("cartridgeData"):
            lines = [ln for ln in inter["cartridgeData"].split("\n") if ln.strip()][:5]
            inter["cartridgeData"] = "\n".join(lines)


def narrative_len(obj) -> int:
    total = 0
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in ("bodyText", "displayText", "description", "cartridgeData", "messageText", "text", "issuer", "footerText", "fact", "maraObservation") and isinstance(v, str):
                total += len(v)
            elif k == "fields":
                for f in v:
                    for sk in ("suspicionNote", "value", "key"):
                        if isinstance(f.get(sk), str):
                            total += len(f[sk])
            else:
                total += narrative_len(v)
    elif isinstance(obj, list):
        for item in obj:
            total += narrative_len(item)
    return total


def main():
    stats = {"cases": 0, "categories_added": 0, "terminals": 0}
    for path in sorted(CASES_DIR.glob("cases_ch*.json")):
        data = json.loads(path.read_text())
        for case in data:
            trim_case(case)
            stats["cases"] += 1
            stats["categories_added"] += len(case.get("investigationCategories", []))
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")

    for path in sorted(LEVELS_DIR.glob("level_*.json")):
        data = json.loads(path.read_text())
        before = narrative_len(data)
        process_level(data)
        after = narrative_len(data)
        stats["terminals"] += 1
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")

    print(json.dumps(stats, indent=2))


if __name__ == "__main__":
    main()
