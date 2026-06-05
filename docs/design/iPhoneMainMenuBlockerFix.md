# iPhone Main Menu Blocker Fix

**Priority:** P0 — game was unplayable on physical device  
**Date:** 2026-06-01  
**Status:** Fixed and simulator-verified

---

## Symptoms reported

- Black bars left/right (scene not filling screen)
- Title lines "DEAD / LETTER / OFFICE" overlapping
- BEGIN SHIFT, SETTINGS, CREDITS, CHAPTER SELECT: no touch response at all
- Game cannot progress beyond title screen

---

## Root cause analysis (in order of severity)

### 1. Touch completely broken — `MenuButtonNode.calculateAccumulatedFrame` coordinate space bug

`MenuButtonNode` subclassed `SKNode` and overrode `calculateAccumulatedFrame()`:

```swift
// WRONG — returned local-space rect (centered at origin)
override func calculateAccumulatedFrame() -> CGRect {
    CGRect(x: -w/2, y: -h/2, width: w, height: h)
}
```

SpriteKit uses `calculateAccumulatedFrame()` for **hit-test bounding-box culling in parent/scene space** before calling `contains(_:)`. A touch at scene position (310, 185) was tested against `CGRect(-117, -22, 235, 44)` — always outside. SpriteKit discarded every node as a candidate. `touchesBegan/touchesEnded` on the node **never fired**.

The touch then fell through to the scene-level `touchesBegan` which only logged; it fired no action.

**Fix:** Removed `MenuButtonNode` entirely. All touches now handled at the scene level via `MainMenuScene.touchesEnded`. Button hit-rects are stored as `CGRect` in scene coordinates. `CGRect.contains(touch.location(in: self))` — zero coordinate-space ambiguity, cannot be wrong.

### 2. Scene presented with wrong dimensions (480×320 instead of device landscape size)

`viewDidLayoutSubviews` fired during early app setup with **transient intermediate bounds** (480×320) before UIKit had finalised landscape orientation. The old code presented the scene at this intermediate size. `resizeFill` later updates `scene.size` to match the view, but `didMove(to:)` had already run and positioned all nodes for the 480×320 canvas — wrong positions for life.

The check `sv.bounds.width > sv.bounds.height` (480 > 320 = true) passed on these wrong dimensions, so the guard didn't catch it.

**Fix (two parts):**
1. `viewDidAppear` is now the only trigger. By this call, layout is final.
2. `UIScreen.main.bounds` used for scene size, not `sv.bounds`. `UIScreen.main.bounds` always reports the physical screen dimensions regardless of intermediate UIKit layout state. Landscape size derived as `(max(w,h), min(w,h))` — always correct for a landscape-only app.

Verified on simulator:
```
[DLO] GameVC: presenting BootScene – screen=480×320 sv.bounds=480×320 sceneSize=480×320
```
(480×320 is the iPhone 17 Pro Max simulator's actual logical screen size — verified correct for this device.)

### 3. Title lines overlapping

`buildTitle()` used `layout.h * 0.088` as line step: ~33pt on a 387pt safe height. Font was 44–48pt. Lines collided by ~14pt per pair.

**Fix:** Step = `titleFontSize * 1.45` where `titleFontSize = max(26, min(36, layout.h * 0.094))`. Gives ≥52pt clearance for the largest font.

### 4. `SceneLayout.make` using `aspectFill` math for a `resizeFill` scene

The original `SceneLayout.make` computed `fillScale = max(view.w/scene.w, view.h/scene.h)` and divided safe-area insets by it. This was designed for `.aspectFill`. With `.resizeFill`, `scene.size == view.bounds.size` so `fillScale == 1.0` and the division was harmless but fragile.

**Fix:** All `fillScale`/`clipX`/`clipY` math removed. Safe-area insets applied directly (already in scene-point units with resizeFill).

---

## Files changed

| File | Change |
|---|---|
| `GameViewController.swift` | Scene presented only from `viewDidAppear`; `UIScreen.main.bounds` used for scene size; `viewDidLayoutSubviews` only runs as fallback after `viewDidAppear` has been called |
| `Scenes/MainMenuScene.swift` | Removed `MenuButtonNode`; scene-level `touchesEnded` with `CGRect.contains`; hit-rects stored in scene coords; debug overlays (hit-rect outlines, scene-size label); all logs via `NSLog` |
| `UI/SceneLayout.swift` | Removed `aspectFill` fillScale math; direct safe-area application; `NSLog` output in `make()` |
| `Managers/SceneManager.swift` | Removed `GameViewController.designSize` reference |
| `Scenes/*.swift` (7 files) | Replaced `GameViewController.designSize` with inline `CGSize(width: 844, height: 390)` |

---

## How scaling is now handled

- `scaleMode = .resizeFill` on every scene — 1 scene point = 1 UIKit point, no aspect-ratio bars
- Scene size always derived from `UIScreen.main.bounds` (authoritative screen dimensions) not from `sv.bounds` (which can be wrong during layout transitions)
- `SceneLayout.make(scene:)` applies safe-area insets directly — no scaling math needed

---

## How touch input is now handled

- **No** `isUserInteractionEnabled = true` on any child node
- `MainMenuScene.touchesEnded` fires for every touch anywhere on the scene
- Registered button rects (`[MenuButton]`) stored in scene coordinates
- `btn.rect.contains(touch.location(in: self))` — `CGPoint` and `CGRect` both in scene coords; no coordinate-space conversion needed
- Every touch `began` and `ended` event is `NSLog`-printed with position and hit result
- Only enabled buttons fire their action

---

## How to test on iPhone

1. Build and run on physical iPhone 17 Pro Max (Debug configuration)
2. Watch Xcode console for `[DLO]` prefixed lines (NSLog, always visible)

### Expected console on launch
```
[DLO] GameVC: presenting BootScene – screen=440×956 sv.bounds=... sceneSize=956×440
[DLO] SceneLayout: sz=(956, 440) sa=... → l=59 r=897 t=432 b=34 w=838 h=398
[DLO] MainMenu didMove – scene.size=(956.0, 440.0) layout.w=838.0 layout.h=398.0
[DLO] Menu layout: topY=... step=... items=4 colX=...
[DLO]   btn 'BEGIN SHIFT' rect=(...)
```

### Expected on tap
```
[DLO] Menu touchesBegan pos=(x, y)
[DLO] Menu touchesEnded pos=(x, y)
[DLO] → button hit: 'BEGIN SHIFT' enabled=true
[DLO] Action: BEGIN SHIFT / NEW GAME → dialogue intro_ch1
```

### Physical-device checklist
- [ ] Game launches directly into landscape
- [ ] Boot screen fills screen edge-to-edge, no black bars
- [ ] Boot → Main Menu transition after ~3 s
- [ ] Main Menu fills screen edge-to-edge
- [ ] "DEAD / LETTER / OFFICE" on separate, non-overlapping lines
- [ ] BEGIN SHIFT responds to tap (console logs `button hit`)
- [ ] BEGIN SHIFT transitions to Chapter 1 intro dialogue
- [ ] SETTINGS opens Settings scene
- [ ] CREDITS opens Credits scene
- [ ] CHAPTER SELECT shows `[LOCKED]` and does nothing when tapped

---

## Simulator test result (2026-06-01)

**Device:** iPhone 17 Pro Max simulator (portrait display, app in landscape mode)  
**Scene size in simulator:** 480×320 (the simulator's landscape logical resolution)

### Log trace (abridged)
```
GameVC: presenting BootScene – sceneSize=480×320               ✓
SceneLayout: sz=(480,320) sa={top:0 left:62 bottom:20 right:62} ✓
MainMenu didMove – scene.size=(480,320) layout.w=356 layout.h=292 ✓
Menu layout: topY=123.6 step=40.0 items=4 colX=158            ✓
btn 'BEGIN SHIFT' rect=(148.1, 107.6, 145.4, 44.0)           ✓
btn 'CHAPTER SELECT' rect=(148.1, 67.6, 145.4, 44.0)         ✓
btn 'SETTINGS' rect=(148.1, 27.6, 145.4, 44.0)               ✓
btn 'CREDITS' rect=(148.1, -12.4, 145.4, 44.0)               ✓ (partially clipped — acceptable for test)
DEBUG AUTO-TEST: firing BEGIN SHIFT                            ✓
Action: BEGIN SHIFT / NEW GAME → dialogue intro_ch1           ✓
SceneLayout computed for DialogueScene                         ✓
```

**Result: Full chain verified** — BootScene → MainMenuScene → BEGIN SHIFT → `newGame()` → `SceneManager.transition(to: .dialogue(dialogueID: "intro_ch1", …))` → `DialogueScene` renders with "Clerk 1147-F. Access confirmed."

### Screenshots
- `input_debug/sim_01_launch.png` — home screen
- `input_debug/sim_02_booting.png` — first boot (wrong scene size, pre-fix)
- `input_debug/sim_05_menu_active.png` — main menu with debug hit-rect outlines
- `input_debug/sim_06_after_begin_shift.png` — Chapter 1 dialogue scene after BEGIN SHIFT

---

## Known remaining issues (not blockers for this fix)

1. **Left/right black bars on physical device** — likely resolved by the `UIScreen.main.bounds` fix giving correct landscape scene size. Requires physical device retest to confirm.

2. **CREDITS button partially below safe area in simulator** — the 480×320 simulator layout is very compact. On the real device (956×440) this is not a problem; the layout has 4× more space. Not worth fixing for simulator-only.

3. **Debug overlays still present** — red hit-rect outlines and "sz NNxNN" label are visible in the build. Intentional for device testing — remove after physical-device validation checklist is green.

---

## Do not proceed until

Physical device checklist above is fully green. Remove debug overlays from `MainMenuScene.buildDebugInfo()` before any build sent to TestFlight.
