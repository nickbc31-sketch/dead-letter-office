# Mara Confidence System

## Overview

Immediate emotional feedback after every desk decision. Mara reacts; the player infers confidence. The game never says CORRECT, INCORRECT, or WRONG ANSWER.

## Files Modified

| File | Change |
|------|--------|
| `DeadLetterOffice/Managers/MaraConfidenceAssessor.swift` | **New** — assessment, reactions, shift-evaluation copy |
| `DeadLetterOffice/Managers/GameState.swift` | `caseConfidence` map + `recordConfidence()` |
| `DeadLetterOffice/Managers/SaveManager.swift` | Persist `caseConfidence` in save data |
| `DeadLetterOffice/Scenes/DeskScene.swift` | Mara reaction panel after stamp; confidence recording |
| `DeadLetterOffice/Scenes/ChapterCompleteScene.swift` | Enhanced shift evaluation per case |
| `DeadLetterOffice.xcodeproj/project.pbxproj` | Build entry for assessor |

## Confidence System Implementation

### Assessment categories

- **correct** — chosen action matches `correctLegalActionID` on the case
- **partial** — player noticed something or chose a weaker-but-related action
- **incorrect** — blind or contradictory choice relative to case evidence

### Scoring rules (`MaraConfidenceAssessor.assess`)

1. Action ID equals `correctLegalActionID` → **correct**
2. Action is `flag_anomaly` (but not the preferred action) → **partial**
3. Player logged a case deduction (`deduction_{caseID}_*`) → **partial**
4. Action investigation weight within 1 step of preferred weight → **partial**
5. `approve` on a case with critical contradictions when preferred action is stronger → **incorrect**
6. Otherwise → **incorrect**

Action weights (higher = more thorough):

| Action | Weight |
|--------|--------|
| approve | 0 |
| archive | 1 |
| reject | 2 |
| censor | 3 |
| flag_anomaly / illegal_forward | 4 |
| broadcast / control / erasure | 5 |

### Persistence

`GameState.caseConfidence: [String: CaseConfidenceLevel]` saved in `SaveData.caseConfidence`. Recorded on every non-training desk stamp. No branching yet — hooks for Chapter 8 summaries and future systems.

### Mara reaction panel

Shown immediately after stamp (1.55s), before the existing PMCA action result panel:

```
CASE PROCESSED
MARA: "That makes sense."
```

Uses `portrait_mara` when the asset is available. Training mode shows reactions but does not persist confidence.

## Example Reactions

| Level | Examples |
|-------|----------|
| Correct | "That makes sense." / "Everything lines up." / "Good. That explains the discrepancy." |
| Partial | "Maybe." / "I still have questions." / "Something feels unresolved." |
| Incorrect | "No..." / "Something doesn't add up." / "Those dates don't make sense." |

Reaction line is chosen deterministically from the case ID hash (stable per case, varied across cases).

## Shift Evaluation

Per-case block:

```
CASE C001
Decision: APPROVED
PMCA Assessment: Accepted.
Mara Assessment: Potential anomaly overlooked.
Citizen Impact: Unknown.
```

Shift footer when confidence data exists:

```
SHIFT RECORD
Cases investigated: 5
Cases with unresolved questions: 2
Cases overlooked: 1
```

## Validation

Build target: iOS Simulator (`xcodebuild -scheme DeadLetterOffice -destination 'generic/platform=iOS Simulator'`).

| Check | Status |
|-------|--------|
| Every desk decision shows Mara reaction | Implemented in `performAction` / `presentDecisionFeedback` |
| Reactions match confidence level | Pool per level in `MaraConfidenceAssessor` |
| No answers revealed | Only subjective Mara lines; no correct-action text |
| No progression changes | Confidence is recorded only; consequences unchanged |
| Shift evaluation functions | `ChapterCompleteScene.buildShiftEvaluation` enhanced |
| Build compiles | **SUCCEEDED** (`xcodebuild`, generic iOS Simulator) |

## Design Constraints

- Never punitive copy ("you were wrong")
- Never quiz language
- Player target feeling: *"Did I make the right call?"* not *"The game told me I was wrong."*
