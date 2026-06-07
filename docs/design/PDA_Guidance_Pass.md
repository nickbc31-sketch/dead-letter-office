# PDA Guidance & Player Thinking Pass

**Date:** 2026-06-07  
**Constraint:** PDA structure unchanged (Journal / Objectives / Discoveries). No puzzle solutions. No progression changes.

---

## Summary

The PDA now supports **deductive thinking** without becoming a walkthrough. Guidance points at *what to compare* — never *what the answer is*.

| Tab | Enhancement |
|-----|-------------|
| **Objectives** | `CURRENT TASK` + `WHAT TO LOOK FOR` per investigation lead |
| **Discoveries** | `DISCOVERY` headline + `MARA'S THOUGHTS` beneath each entry |
| **Journal** | `CURRENT INVESTIGATION` checklist on desk + capped bullets (max 5/section) |
| **Desk assist** | Category checklist while working an active case |
| **Stuck support** | Escalating Mara hints on repeated PDA opens (never spoilers) |
| **Terminals** | Mara observations clamped to 1–2 sentences |

**Build:** `xcodebuild` → **BUILD SUCCEEDED**

---

## 1. Objectives Improvements

Investigation leads now render as guided tasks, not prose blocks.

**Before:**
```
INVESTIGATION LEADS

KEY FACTS
• Relay Building sits on the desk route...
OPEN QUESTIONS
• Inner checkpoints use citizen-linked access codes.
```

**After:**
```
INVESTIGATION LEADS

CURRENT TASK
Review desk cases linked to Transit Line 9.

WHAT TO LOOK FOR
Compare death records with transit filings.
```

Field objectives use the same `CURRENT TASK` label when `objectiveText` is present on platform levels.

Implementation: `PDAGuidanceResolver.investigationTasks` / `investigationLookFor` with fallbacks from catalog bullets.

---

## 2. Discovery Improvements

Discoveries keep the evidence-board structure and add Mara's voice.

**Example — Relay buffer:**
```
DISCOVERY
Relay Node 7 buffer holds 47 messages in transit.

KEY FACTS
• Routing tag EVN-ROUTING-0442 — Quiet Choir relay buffer.
• Scheduled deletion logged — routing anomaly at Node 7.

OPEN QUESTIONS
• Who scheduled the buffer deletion?

LINKED PEOPLE
• Elias Venn

MARA'S THOUGHTS
Forty-seven queued messages. Someone's routing off the official channel.
```

- First fact promoted to `DISCOVERY` headline
- Remaining facts under `KEY FACTS` (max 5 bullets/section)
- `LINKED PEOPLE / LOCATIONS / CASES` capped at 5 each
- `MARA'S THOUGHTS` from `PDAGuidanceResolver.discoveryThoughts` (40+ explicit mappings + tag fallbacks)

---

## 3. Mara's Thoughts Implementation

| Context | Source | Rules |
|---------|--------|-------|
| Discoveries tab | `PDAGuidanceResolver.maraThought(for:)` | One sentence; interpretation not data |
| Desk stuck support | `escalatingDeskHint(caseFile:openCount:)` | 3 levels; never states contradiction |
| Terminals | `appendMaraObservation` + `clampMara()` | Max 2 sentences |

**Stuck escalation (Case C01 — Marr):**

| PDA opens (same case) | Mara hint |
|----------------------|-----------|
| 1 | *(checklist only)* |
| 2 | Something about these records doesn't feel right. |
| 3 | The timing looks unusual. |
| 4+ | Maybe compare the transit report with the death record. |

Tracked via `PDAJournalState.deskCasePDAOpenCounts` — incremented on desk PDA open and when viewing Objectives/Journal.

---

## 4. Current Investigation Checklist

When the player opens the PDA on desk with an active case, Objectives and Journal prepend:

```
CURRENT INVESTIGATION

Citizen: Lina Marr
Review:
□ DEATH RECORD
□ TRANSIT
□ HOUSING

MARA'S THOUGHTS
The timing looks unusual.
```

- Checklist built from `CaseFile.investigationCategories`
- Citizen name shown (recipient, or sender if no recipient)
- `□` items are categories to review — not answers
- Escalating Mara hint appears after 2+ opens

Passed via `activeCaseID` from `DeskScene` → `PDAJournalPanel.build` → `objectivesBody` / `journalBody`.

---

## 5. Example Hints

### Objectives — guidance only

| Task | Look for |
|------|----------|
| Investigate Relay Building routing. | Check how checkpoint codes relate to case IDs. |
| Trace Block P03 and Marr Unit 312. | Check housing seals against appeal timestamps. |
| Map Route 7-B beneath sealed district. | Compare transit manifests with death locations. |

### Stuck desk hints — escalating, not solving

```
Level 1: Something about these records doesn't feel right.
Level 2: The timing looks unusual.
Level 3: Maybe compare the transit report with the death record.
```

Never: *"Death was recorded at 14:22 before the 15:04 crash."*

### Discovery thoughts — memorable interpretation

| Discovery | Mara's thought |
|-----------|----------------|
| Transit timing anomaly | That's the second transit timing anomaly I've seen. |
| Routing data altered | Someone is changing records after approval. |
| Jun Vale credential | Declared dead. Still logged in on the infrastructure. |
| Elias relay packet | Erased from the system — not killed. Still composing on the relay. |

---

## 6. Example Terminal Observations

All terminal Mara lines pass through `PDAGuidanceResolver.clampMara()` (max 2 sentences).

**Good:**
```
MARA: "Forty-seven queued messages. That's far too many."
MARA: "Somebody manually changed these routes."
MARA: "Checkpoint codes follow case IDs. Desk won't show the buffer."
```

**Avoided:**
- Multi-paragraph lore dumps
- Spoiler contradictions
- Walkthrough steps

---

## 7. Journal Tab

Unchanged structure for case decisions and shift notes. Enhancements:

- `CURRENT INVESTIGATION` checklist when on desk (same as Objectives)
- Case `keyPoints` capped at 5 bullets
- Summary bullets capped at 5 per section
- Linked sections capped at 5 items

No additional text volume — concise bullets only.

---

## 8. Files Modified

| File | Change |
|------|--------|
| `Managers/PDAGuidanceResolver.swift` | **New** — tasks, look-for, thoughts, escalation, caps |
| `Managers/PDAJournalManager.swift` | Body formatters, open-count tracking, discovery layout |
| `UI/PDAJournalPanel.swift` | `activeCaseID` parameter for desk context |
| `Scenes/DeskScene.swift` | Pass active case, track PDA opens |
| `Scenes/PlatformScene.swift` | Clamp terminal Mara observations |

---

## 9. Validation

| Check | Result |
|-------|--------|
| PDA tabs (Journal / Objectives / Discoveries) | Functional |
| Shift 1→8 progression | Unchanged |
| Journal unlock handlers | Intact |
| Spoiler hints in escalation | None — hints stop at "compare X with Y" |
| Build | **SUCCEEDED** |

---

## Design Intent

The PDA should feel like **Mara's investigator notebook**:

- **Guided** — player knows what to investigate and what to compare
- **Not led** — no answers, no walkthrough, no wiki
- **Memorable** — Mara's thoughts stick; raw terminal data fades

Players should know **what they are investigating** without being told **the answer**.
