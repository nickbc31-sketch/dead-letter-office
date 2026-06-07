# Player Onboarding System

**Pass:** Player Guidance & Onboarding  
**Goal:** Teach investigation without revealing solutions.

---

## Overview

Three systems work together:

| System | Location | Purpose |
|--------|----------|---------|
| **Field Notes** | PDA → Field Notes | Mara's active observations — not evidence, discoveries, or objectives |
| **Investigation Manual** | PDA → Manual | In-universe PMCA training reference; anomaly categories unlock gradually |
| **PMCA Training Simulation** | Main Menu → PMCA TRAINING | Optional, replayable desk tutorial (Cases A/B/C) |

---

## 1. PDA Field Notes

### Design rules

- Observations only — never answers or puzzle solutions
- Separate from Journal, Objectives, and Discoveries
- Deduplicated by ID; capped at 20 entries
- Persist in `PDAJournalState.fieldNotes` / `fieldNoteIDs`

### Example observations

- Death timing looks unusual.
- I've seen this routing code before.
- Someone is modifying records after approval.

### Population hooks

| Trigger | Source |
|---------|--------|
| Case anomaly hook displayed | `DeskScene.displayCase` |
| Suspicious field opened (training) | `DeskScene.switchToDocument` |
| Anomaly log opened | `DeskScene.showAuditOverlay` |
| PDA reopened on stuck case | `PDAJournalManager.currentInvestigationSection` |
| Terminal Mara observation | `PlatformScene` terminal read |
| Training Mara commentary | `DeskScene.showTrainingMaraCommentary` |

---

## 2. PMCA Investigation Manual

### Sections (unlock gradually)

1. **Desk Workflow** — document tabs, comparison, anomaly log, PDA, stamp
2. **Death Record Anomalies**
3. **Transit Anomalies**
4. **Housing Anomalies**
5. **Communication Anomalies**
6. **Employment Anomalies**

Locked sections appear as `[ LOCKED — TITLE ]` until unlocked.

### Unlock triggers

| Section | Unlock |
|---------|--------|
| Desk Workflow | First story shift start or training simulation entry |
| Death Record | Open death certificate (story or training) |
| Transit | Open incident report |
| Housing | Open relocation notice |
| Communication | Open message or phrase list |
| Employment | Training Case C or corporate/citizen record in training |

Implementation: `InvestigationManual.swift` + `PDAJournalState.unlockedManualSectionIDs`.

---

## 3. PMCA Training Simulation

### Access

- Main Menu → **PMCA TRAINING**
- Launches `DeskScene` with `chapterID == "training"`
- Optional, replayable, no story save impact

### Isolation rules

Training mode does **not**:

- Apply `GameState` consequences or flags
- Record case decisions
- Increment deduction counter
- Advance chapter progression

Training **may**:

- Unlock manual sections (teaching progress)
- Add generic field notes
- Persist manual unlocks to save (non-spoiler)

### Training cases (`cases_training.json`)

| Case | Teaches | Citizens | Correct action |
|------|---------|----------|----------------|
| **A** | Document tabs, timestamps | Kess family (generic IDs) | Approve — records align |
| **B** | Anomaly log, PDA, comparison | Venn family | Flag anomaly — death before incident filed |
| **C** | Multi-document, categories, decision | Orte family | Flag anomaly — housing/employment conflict |

No story characters, conspiracy references, or spoilers.

### Guided Mara commentary

Displayed as right-panel toasts and stored in Field Notes:

- *"Let's compare these records."*
- *"The dates don't match."*
- *"The anomaly log can help narrow things down."*
- *"The PDA stores useful observations."*

### Completion

All three cases stamped → certification overlay → Main Menu.

---

## 4. PDA Hub (unchanged tabs + two additions)

Existing: Journal, Objectives, Discoveries  
Added: **Field Notes**, **Manual**

Field Notes and Manual omit the shift selector bar.

---

## 5. Success criteria

A new player who completes PMCA Training should understand:

1. How to investigate (open docs, read fields, use anomaly log)
2. How to compare documents (timestamps, status lines)
3. What anomalies are (cross-record contradictions by category)
4. How to use the PDA (Field Notes + Manual as memory, not proof)
5. How to make a decision (stamp action after review)

---

## 6. Files

| File | Role |
|------|------|
| `InvestigationManual.swift` | Manual content + unlock API |
| `PDAJournalManager.swift` | Field notes state + body formatters |
| `PDAJournalPanel.swift` | Hub buttons + section views |
| `cases_training.json` | Three training cases |
| `DeskScene.swift` | Training mode + Mara commentary |
| `MainMenuScene.swift` | Training menu entry |
| `PDAGuidanceResolver.swift` | Training desk escalation hints |

---

## 7. Test plan

- [ ] Main Menu → PMCA TRAINING launches desk
- [ ] Training Cases A/B/C complete and return to menu
- [ ] PDA → Field Notes shows Mara observations
- [ ] PDA → Manual unlocks sections during training
- [ ] Story shift decisions unaffected by training replay
- [ ] Simulator build succeeds
