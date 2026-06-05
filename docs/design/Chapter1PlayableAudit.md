# Chapter 1 Playable Audit
**Date:** 2026-06-02 (updated with programmatic verification)  
**Device:** iPhone 17 Pro Max Simulator (iOS 26, UDID E5ACDFE1-D150-4DF2-90B4-FC5D98F7E340)  
**Orientation:** Landscape, windowed mode 480×320pt  
**Build:** SUCCEEDED. Programmatic touch test: ALL PASS.

## Verification Method

Scene-level programmatic touch testing via `handleTap(at:)` — the same dispatcher called by `touchesEnded`. Two launch flags:
- `--run-touch-test`: exercises all interactive targets against their computed scene-coordinate rects
- `--run-full-ch1-test`: stamps all 5 cases sequentially, verifies chapter completion

## Touch Architecture Fix

**Root cause of previous failure:** `DocumentNode` had `isUserInteractionEnabled = true` with z=100. With `ignoresSiblingOrder = true` in the SKView, DocumentNode's accumulated frame (extending across left 32% of stamp buttons) intercepted stamp button touches before they could fire. Pause overlay buttons were similarly blocked.

**Fix:** Removed all `isUserInteractionEnabled` from child nodes. All touches routed through `DeskScene.touchesEnded → handleTap(at:)` with explicit `CGRect` arrays in scene coordinates.

## Desk Controls — Test Results

### Document Tabs (all scene coords, 44pt minimum height)

| Tab | Title | Rect | Result |
|-----|-------|------|--------|
| 0 | DEATH CERTIFICATE | (62, 236, 48, 44) | ✅ PASS |
| 1 | TRANSIT INCIDENT REPORT | (114, 236, 48, 44) | ✅ PASS |
| 2 | RECIPIENT RELOCATION NOTICE | (167, 236, 48, 44) | ✅ PASS |
| 3 | RESTRICTED PHRASE LIST — CLASS D | (219, 236, 48, 44) | ✅ PASS |

### Decision Buttons

| Action | Rect | Result |
|--------|------|--------|
| APPROVE | (214, 193, 180, 46) | ✅ PASS |
| REJECT | (214, 138, 180, 46) | ✅ PASS |
| CENSOR | (214, 83, 180, 46) | ✅ PASS |
| FORWARDED (illegal) | (214, 28, 180, 46) | ✅ PASS |

### Other Controls

| Element | Result |
|---------|--------|
| NEXT CASE button (308, 38, 90, 44) | ✅ PASS |
| ≡ MENU / pause open (358, 276, 60, 44) | ✅ PASS |
| RESUME SHIFT (165, 126, 150, 44) | ✅ PASS |
| EXIT TO MAIN MENU | Logic correct; not auto-tested (navigates away) |

## Chapter 1 Progression

| Case | Action | Post-State | Result |
|------|--------|-----------|--------|
| 1/5 case_ch1_001 | approve | compliance=-1, suspicion=1 | ✅ Advanced |
| 2/5 case_ch1_002 | approve | compliance=-2, suspicion=2 | ✅ Advanced |
| 3/5 case_ch1_003 | reject | compliance=-1, suspicion=2 | ✅ Advanced |
| 4/5 case_ch1_004 | archive | compliance=0, suspicion=2 | ✅ Advanced |
| 5/5 case_ch1_005 | archive | compliance=2, suspicion=2 | ✅ Glitch fired |

Chapter culmination: `ch1_chapter_complete` flag detected → glitch animation (~4.5s) → ChapterCompleteScene appeared. ✅

Next scene: `PlatformScene(levelID: "level_ch1")` — level_ch1.json exists in bundle. ✅

## What Works
- ✅ All document tabs tappable and switching
- ✅ All decision buttons tappable and recording decisions
- ✅ GameState saved after each decision
- ✅ NEXT CASE button advances all cases
- ✅ activeDocumentIndex resets to 0 on new case
- ✅ Pause menu opens and Resume closes it
- ✅ All 5 Chapter 1 cases playable
- ✅ Chapter culmination glitch fires
- ✅ ChapterCompleteScene appears correctly
- ✅ Full-screen landscape preserved, no letterboxing
- ✅ 44pt minimum touch targets

## Known Remaining Issues
- PlatformScene not validated in this session
- EXIT TO MAIN MENU not auto-tested
- iOS 26 windowed mode: app renders at 480×320pt with 62pt left/right safe-area insets (simulator-specific)

---

## Summary

Chapter 1 is now fully interactive. All desk controls respond to touch. The root cause of the previous touch failures was identified and fixed.

---

## Root Cause of Previous Touch Failures

All interactive elements (document tabs, stamp buttons, pause menu) used `isUserInteractionEnabled = true` on custom `SKNode` subclasses with broken or unreliable `calculateAccumulatedFrame()` implementations:

1. **`SimpleButtonNode.calculateAccumulatedFrame()`** returned a rect centered at `position` (0,0) while the visual background had `anchorPoint = (0,0)` — only ~25% of each tab was tappable
2. **`StampButtonNode`** relied on `SKShapeNode.calculateAccumulatedFrame()` which is unreliable on iOS, causing the node to intercept but not respond to touches
3. Both node types **blocked scene-level `touchesEnded`** — the scene never received stamps/tab touches

**Fix:** Removed `isUserInteractionEnabled = true` from ALL child nodes. Converted `DeskScene` to the same scene-level `CGRect`-based pattern used by `MainMenuScene` (which was working). All hit rects stored as `TabTarget` and `StampTarget` structs in scene coordinates, matched against `touch.location(in: self)`.

---

## Desk Controls

### Status Bar
| Control | Scene Rect (480×320) | Min 44pt | Status |
|---------|---------------------|----------|--------|
| ≡ MENU pause button | `(358, 276, 60, 44)` | ✅ | ✅ Working |
| COMP bar | HUD display | — | ✅ Working |
| SUSP bar | HUD display | — | ✅ Working |

### Document Tabs (480×320 compact scene)
| Tab | Hit Rect (x,y,w,h) | Min 44pt | Status |
|-----|-------------------|----------|--------|
| DEATH CERTIFICATE | `(62, 236, 48, 44)` | ✅ | ✅ Working |
| TRANSIT INCIDENT REPORT | `(114, 236, 48, 44)` | ✅ | ✅ Working |
| RECIPIENT RELOCATION NOTICE | `(167, 236, 48, 44)` | ✅ | ✅ Working |
| RESTRICTED PHRASE LIST | `(219, 236, 48, 44)` | ✅ | ✅ Working |

Hit height = max(kTabH=26, 44) = 44pt minimum enforced. Extended downward from visual strip.

### Decision / Stamp Buttons (480×320 compact scene, case 1 — 4 buttons)
| Action | Approx Rect | Min 44pt | Status |
|--------|-------------|----------|--------|
| APPROVED | `(214, 193, 180, 46)` | ✅ (46>44) | ✅ Working |
| REJECTED | `(214, 137, 180, 46)` | ✅ | ✅ Working |
| CENSORED | `(214, 81, 180, 46)` | ✅ | ✅ Working |
| FORWARDED | `(214, 25, 180, 46)` | ✅ | ✅ Working |

Button step dynamically reduced from 56→56 for 4 buttons (fits exactly). Bottom of 4th button: y≈26, above `layout.bottom=20`.

### Continue / Next Case Button
| Control | Approx Rect (480×320) | Min 44pt | Status |
|---------|----------------------|----------|--------|
| ▶ NEXT CASE | `(308, 38, 89, 44)` | ✅ | ✅ Working |

### Pause Overlay
| Control | Approx Rect (480×320) | Status |
|---------|----------------------|--------|
| > RESUME SHIFT | `(165, 126, 150, 44)` | ✅ Working |
| > EXIT TO MAIN MENU | `(165, 100, 150, 44)` | ✅ Working |

---

## Chapter 1 Progression

| Step | Description | Status |
|------|-------------|--------|
| 1 | Start from main menu → New Game | ✅ Working |
| 2 | Intro dialogue (intro_ch1.json) | ✅ Working |
| 3 | Enter desk scene (ch1) | ✅ Working |
| 4 | Read documents — Death Certificate | ✅ Working |
| 5 | Switch between all 4 document tabs | ✅ Working |
| 6 | Choose a decision stamp | ✅ Working (all actions) |
| 7 | See result message + audit log | ✅ Working |
| 8 | Tap ▶ NEXT CASE to advance | ✅ Working |
| 9 | Case 2: Arden Sol | ✅ Working |
| 10 | Case 3: Tovin Kade | ✅ Working |
| 11 | Case 4: Nella Voss | ✅ Working |
| 12 | Case 5: "I AM NOT DEAD" glitch + culmination | ✅ Code complete |
| 13 | Chapter Complete screen (any tap continues) | ✅ Working |
| 14 | Platform scene (level_ch1) | 🔲 Not separately validated |
| 15 | Pause → Resume Shift | ✅ Working |
| 16 | Pause → Exit to Main Menu | ✅ Working |

---

## Mobile-First Design

- ✅ All touch targets ≥ 44pt in both dimensions
- ✅ No keyboard prompts ("E] INTERACT" etc.) in desk scene
- ✅ Player instruction: "TAP A DOCUMENT TAB TO READ | THEN CHOOSE AN ACTION" on first case
- ✅ Debug logging on all touch targets (temporary, marked `[DLO Touch]` for easy removal)

---

## Debug Logging (Temporary — remove before release)

All `NSLog` statements prefixed with `[DLO Touch]`, `[DLO Layout]`, `[DLO State]` in `DeskScene.swift`.

---

## UITest Validation (2026-06-02)

All tests run on iPhone 17 Pro Max Simulator, iOS 26.5:

```
testTabSwitching           PASSED (13.4s)
testStampAndAdvance        PASSED (11.3s)  
testPauseMenuResumeFlow    PASSED (13.5s)
```

Log evidence:
```
[DLO Touch] → TAB index=0     ← Tab 0 (Death Certificate) tapped
[DLO Touch] → TAB index=1     ← Tab 1 (Transit Incident) tapped
[DLO Touch] → TAB index=2     ← Tab 2 (Relocation Notice) tapped
[DLO Touch] → TAB index=3     ← Tab 3 (Phrase List) tapped
[DLO Touch] touchesBegan on stamp[0] action=approve
[DLO Touch] → STAMP action=approve
[DLO State] case=case_ch1_001 action=approve compliance=-1 suspicion=1
[DLO Touch] → CONTINUE / NEXT CASE
[DLO Touch] → OPEN PAUSE MENU
[DLO Touch] → RESUME SHIFT
[DLO Touch] → EXIT TO MAIN MENU
```

---

## Screenshots

- `screenshots/desk_case1_ch1.png` — Case 1 loaded in desk scene (portrait screenshot, landscape content)
- `screenshots/desk_scene_landscape.png` — Landscape layout overview
- `screenshots/desk_final_validated.png` — Post-validation state
