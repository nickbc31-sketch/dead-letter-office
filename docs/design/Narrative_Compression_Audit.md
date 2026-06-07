# Narrative Compression Audit

**Pass:** Shifts 1–8 (Chapters 1–8)  
**Date:** 2026-06-05  
**Goal:** Reduce reading density without changing story, plot points, chapter structure, or mystery.

---

## Summary

| Area | Items touched | Before (chars) | After (chars) | Reduction |
|------|---------------|----------------|---------------|-----------|
| Case files | 27 cases | 75,955 | 18,813 | **75.2%** |
| Level terminals & field text | 10 level files | 18,543 | 12,396 | **33.1%** |
| Ch1 hardcoded terminals | 3 terminals | ~1,050 | ~420 | **~60%** |
| PDA journal catalog | 57 entries | — | — | Restructured (evidence board) |

**Weighted narrative reduction (cases + levels): ~68%** on compressed text fields (`bodyText`, `suspicionNote`, `displayText`, `contradictions.description`, `cartridgeData`).

Case files exceeded the ~50% target because `bodyText` paragraphs were removed in favour of field-only factual records. Terminals in level JSON were already partially lean; Ch1 terminals and Ch2+ encounter terminals were compressed further, with Mara observations added at display time.

---

## 1. Cases Shortened (27 total)

| Shift | File | Cases | Primary categories |
|-------|------|-------|-------------------|
| 1 | `cases_ch1.json` | 5 | DEATH RECORD, TRANSIT STATUS, HOUSING STATUS, COMMUNICATION RECORD |
| 2 | `cases_ch2.json` | 3 | DEATH RECORD, IDENTITY, ROUTING |
| 3 | `cases_ch3.json` | 6 | HOUSING STATUS, LOCATION, ROUTING, IDENTITY |
| 4 | `cases_ch4.json` | 3 | DEATH RECORD, ROUTING, COMMUNICATION RECORD |
| 5 | `cases_ch5.json` | 3 | IDENTITY, DEATH RECORD, CORPORATE RECORD |
| 6 | `cases_ch6.json` | 3 | TRANSIT STATUS, LOCATION, IDENTITY |
| 7 | `cases_ch7.json` | 3 | IDENTITY, COMMUNICATION RECORD, DEATH RECORD |
| 8 | `cases_ch8.json` | 1 | IDENTITY, DEATH RECORD |

### Compression rules applied

- **`bodyText`:** Cleared when 3+ structured fields carry the facts; otherwise one short sentence.
- **`suspicionNote`:** Converted from cross-reference spoilers to category hints (e.g. "Check timing against related records.").
- **`contradictions.description`:** Anomaly log now gives investigation guidance, never the answer.

### Before / After — Case C01 (Shift 1)

**Before — Death Certificate `bodyText`:**
> The above citizen has been declared deceased following a fatal accident on Transit Line 9. Death occurred at approximately 14:22 on the date above. Cause confirmed as blunt trauma consistent with derailment.

**After:** *(empty — fields carry the record)*

| Field | Value |
|-------|-------|
| Date of Death | 2147.03.12 — 14:22 |
| Cause | Transit accident — Line 9 derailment |

**Before — `suspicionNote` on Date of Death:**
> Certification at 14:22. See TRANSIT INCIDENT REPORT — Report Filed.

**After:**
> Check timing against related records.

**Before — Anomaly log `description`:**
> The death certificate records death at 14:22. The incident report confirms the accident was not logged until 15:04.

**After:**
> Check death record timing against transit status.

The contradiction is now visible from fields alone; the log only points the player at what to compare.

---

## 2. Terminals Shortened

| Source | Terminals compressed |
|--------|---------------------|
| `level_ch2.json` – `level_ch8.json` encounter terminals | 28 |
| `level_ch1_checkpoint_interior.json` | 2 |
| `PlatformScene.swift` hardcoded Ch1 terminals | 3 |

### Mara Observation System (new)

- `maraObservation` field added to `Interactable` and `TerminalEncounterConfig`.
- After terminal read, Mara speaks a one-line summary appended to the panel:
  ```
  — — —
  MARA: "Forty-seven messages queued — someone's routing off the official channel."
  ```
- Ch1 fallback terminals use `maraObservationForTerminal(id:)`.

### Before / After — Relay Node 7 Terminal (Shift 1)

**Before (`PlatformScene` hardcoded `terminal_02`):**
```
PMCA RELAY NODE 7 — INTERNAL LOG

Secondary routing tag: EVN-ROUTING-0442
Destination: QUIET CHOIR RELAY BUFFER

47 messages in transit buffer.
Scheduled deletion: 2147.03.19.

— — —
INNER CHECKPOINT CODE:
Derived from Case 1 victim ID.
Format: 4 digits.
Citizen VC-[XXXX]-M.
— — —

This terminal will be wiped
upon Director's audit completion.
```

**After:**
```
RELAY NODE 7 — ROUTING BUFFER

Tag: EVN-ROUTING-0442
Destination: Quiet Choir buffer

47 messages queued.
12 rerouted.
Scheduled deletion: 2147.03.19.

Checkpoint code: 4 digits from Case 1 ID.

— — —
MARA: "Forty-seven messages queued — someone's routing off the official channel."
```

### Before / After — East Transit Relay Buffer (Shift 2)

**Before:**
```
PMCA RELAY BUFFER — EAST TRANSIT NODE
Unregistered senders in transit: 47
Scheduled deletion: 2147.04.15
Secondary routing class: EVN
Orphan tags logged: 12
Origin infrastructure: UNLOGGED
Note: Buffer contents not visible to desk terminals.
Routing anomaly confirmed.
```

**After:**
```
PMCA RELAY BUFFER — EAST TRANSIT NODE
Unregistered senders in transit: 47
Scheduled deletion: 2147.04.15
Secondary routing class: EVN
Orphan tags logged: 12
Origin infrastructure: UNLOGGED
Note: Buffer contents not visible

— — —
MARA: "They're scheduling deletions before clerks see the buffer."
```

---

## 3. PDA Entries Rewritten (57)

All catalog entries in `PDAJournalManager.swift` now use the evidence-board format:

```
KEY FACTS
• [confirmed fact]
• [confirmed fact]
OPEN QUESTIONS
• [unresolved lead]
```

- **Discoveries tab** renamed header to `EVIDENCE BOARD`.
- **Objectives tab** investigation leads use the same structure.
- Generic filler questions replaced with case-specific open questions where possible.

### Before / After — `ch1_disc_victim_id`

**Before:**
```
CONFIRMED CLUES

• Desk Case 1 — Olen Marr, citizen VC-4471-M.
• Death certificate tied to Transit Line 9 derailment.
• Citizen ID format may matter at inner checkpoints.
```

**After:**
```
KEY FACTS
• Desk Case 1 — Olen Marr, citizen VC-4471-M.
• Death certificate tied to Transit Line 9 derailment.
OPEN QUESTIONS
• Who recorded death before the incident was filed?
```

---

## 4. Gameplay Improvements Introduced

### PMCA Investigation Framework
Recurring categories applied 2–4 per case (see case table above). Players encounter the same record types across shifts and build investigative literacy.

### One Question Per Interaction
- Documents: fields + hints, not paragraphs.
- Terminals: one clue block + Mara summary.
- Anomaly log: guidance only (`Check transit timing.`), not deductions.

### Investigation Over Paperwork
- `bodyText` stripped where fields suffice.
- Cartridge `cartridgeData` capped to 8 lines.
- Environmental signage truncated to single-line labels.
- Player time shifts from reading to comparing, deducing, and field-checking.

### Mara as Memory Anchor
Important discoveries are echoed by Mara immediately after terminal reads, improving memorability without repeating full terminal text.

---

## 5. Files Modified

| Path | Change |
|------|--------|
| `DeadLetterOffice/Data/Cases/cases_ch1.json` – `cases_ch8.json` | Case compression |
| `DeadLetterOffice/Data/Levels/level_ch*.json` | Terminal + field text compression, `maraObservation` |
| `DeadLetterOffice/Models/LevelData.swift` | `maraObservation` on `Interactable` |
| `DeadLetterOffice/Models/PlatformEncounterModel.swift` | `maraObservation` on `TerminalEncounterConfig` |
| `DeadLetterOffice/Managers/PlatformEncounterComposer.swift` | Pass-through |
| `DeadLetterOffice/Scenes/PlatformScene.swift` | Compressed Ch1 terminals, Mara display |
| `DeadLetterOffice/Managers/PDAJournalManager.swift` | Evidence board format |
| `scripts/narrative_compression.py` | Batch compression tooling |

---

## 6. Validation

```
xcodebuild -scheme DeadLetterOffice -destination 'generic/platform=iOS Simulator' build
** BUILD SUCCEEDED **
```

Dialogue files unchanged except where repetition was already absent. Story beats, chapter order, case IDs, flags, and puzzle wiring preserved.

---

## 7. Design Intent

Players should feel like **investigators uncovering a conspiracy**, not **clerks reading endless paperwork**. Every desk document, terminal screen, and PDA entry now answers one question — or asks one — and leaves the deduction to the player.
