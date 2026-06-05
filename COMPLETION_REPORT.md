# Dead Letter Office — Vertical Slice Stabilisation Pass
## Completion Report · 2026-06-05

Build: **SUCCEEDED** (4 consecutive clean builds)  
Visual validation: **iPhone 17 simulator, landscape 874×402pts (safe area: l=62, r=62, b=20)**

---

## COMPLETED

### P1 — Critical Fixes

**1. Chapter Select Back button**  
Already correctly implemented (`SceneManager.shared.transition(to: .mainMenu, from: self)`). Verified — no change required.

**2. Ending C / Erasure loop — root cause fixed**  
Root cause: `DeskScene.resolveNextScene` cascaded through ch4–ch8 (all empty), saved an intermediate `currentChapterID`, and returned `.ending`. On next "Continue Shift" the empty chapter desk loaded immediately → ending again.  
Fix: Content check before advancing chapter — `nextHasCases || nextHasLevel` guard. If no content found, `game_complete` flag is set and ending fires once cleanly.

**3. Completed endings return safely to menu**  
`handleContinueShift` checks `game_complete` flag first; if set, transitions to Credits rather than attempting to resume.

**4. Begin New Shift never loads existing progress**  
`confirmNewShift()` calls `SaveManager.shared.deleteSave()` immediately before `resetForNewGame()`. Save is erased before any transition fires.

**5. Continue Shift resumes correctly**  
Reads `currentChapterID` from persisted save state; falls back to `"ch1"` only when empty.

**6. Main Menu structure**  
CONTINUE SHIFT only shown when `SaveManager.shared.hasSave`. All five items functional. Confirmation dialog: "Your current save will be replaced. This cannot be undone." No-save path skips dialog. Visually confirmed on simulator: all 5 buttons present, correctly labelled.

### P2 — Readability

**7. CreditsScene** — content lines 9 → 11pt  
**8. ChapterSelectScene** — subheader 9 → 10pt; cell title 9 → 11pt; cell subtitle 7 → 9pt; cell labels now scale with `textSizeMultiplier`  
**9. EndingScene** body — 11 → 12pt  
**10. DeskScene message area** — all label sizes scaled by `textSizeMultiplier` (audit tag/label 8→9×mult, message label 9→10×mult)  
**11. DeskScene audit overlay** — anomaly lines 10.5 → 11pt×mult; case ref label 9 → 10pt×mult  
**12. MainMenuScene** — button labels and arrow now scale with `textSizeMultiplier`  

Visual confirmation (iPhone 17 simulator): document tabs, field text, action button labels, anomaly panel, status bar all readable at 874×402pt game resolution.

### P3 — Chapter 1 QA

**13. Chapter 1 logic verified** — 5 cases (C01–C05): correct documents, contradictions, available actions, flag consequences all confirmed. C05 culmination glitch fires on `ch1_chapter_complete` flag. `followUpFlags` applied correctly after `applyConsequences`.

**14. Tutorial onboarding** — Sequential hint overlay added for Ch1 case 0. 4 hints fade in/out sequentially (READ EACH DOCUMENT TAB / ◆ DOTS MARK SUSPICIOUS FIELDS / TAP AUDIT LOG TO REVIEW ANOMALIES / THEN CHOOSE AN ACTION). Gated by `ch1_tutorial_shown` flag (fires once only). Visually confirmed: suspicious field highlighting visible in simulator screenshot.

**15. Case-resolution feedback** — Continue button fades in (0.2s). Case-to-case transition fades new document in (0.25s). Stamp animation already existed (scale 2.5→1.0, 0.12s) and screen flash is preserved.

### P4 — Polish

**16. Pause overlay** — now fades in (0.15s) and fades out (0.1s) on open/close.  
**17. Menu button press feedback** — tapping a menu item triggers alpha flash (1.0→0.4→1.0) on the label before firing action.  
**18. Case-to-case transition** — `presentCurrentCase(animated: true)` fades the first document in when advancing between cases.  
**19. CRT effects** — scanlines (18% opacity black multiply every 4pt), vignette (72% at edges), flicker (±0.08 alpha, 4–10s interval, respects `reducedFlashingEnabled`). Verified by code audit and simulator screenshot.  
**20. bg_terminal_wallpaper** — `bg_terminal_wallpaper` imageset confirmed present; DeskScene reference matches imageset name; 0.82 alpha for subtlety under UI. Confirmed in simulator screenshot: atmospheric background visible without obscuring text.

### P5 — Settings

**21. Text size multiplier** — Applies to: DocumentNode fields/body, DeskScene message area, DeskScene audit overlay, MainMenuScene button labels, ChapterSelectScene cell labels. Range 0.8–1.6, saved/loaded via SaveManager.  
**22. Settings persistence** — `textSizeMultiplier`, `musicVolume`, `sfxVolume`, `subtitlesEnabled`, `reducedFlashingEnabled` all saved to UserDefaults via `SaveManager.save(from:)` / `load(into:)`. `AudioManager` reads volume on player creation. Confirmed by code audit.

### P6 — Content Audit

**23. Chapter 1** — 5 cases, all `requiredFlags = null`, documents/contradictions/actions complete ✅  
**24. Chapter 2** — `cases_ch2.json`, `intro_ch2.json`, `level_ch2.json` all bundled and wired ✅  
**25. Chapter 3** — 6 cases: 4×C09 variants (mutually exclusive via `requiredFlags`), C10 (Fara Dain), C11 (Kell Orvin). `intro_ch3.json`, `level_ch3.json` bundled. ✅  
**26. Chapters 4–8** — No JSON files (expected, correct). Ending loop fix handles gracefully — game sets `game_complete` flag and shows ending rather than crashing or cascading.

---

## FIXED

| # | Issue | Fix Applied |
|---|---|---|
| 1 | Ending C loops forever | `resolveNextScene` content guard + `game_complete` flag |
| 2 | Begin New Shift loads old save | `deleteSave()` on confirm before `resetForNewGame()` |
| 3 | Continue Shift after game_complete re-enters ending | `game_complete` guard → Credits |
| 4 | Confirmation text promised "save remains available" (false) | Changed to "replaced. Cannot be undone." |
| 5 | Document text too small on screen | `textSizeMultiplier` propagated to all major text areas |
| 6 | Menu button tap gave no feedback | Alpha flash on label before firing action |
| 7 | Pause overlay snapped in instantly | Fade-in 0.15s, fade-out 0.1s |
| 8 | Next case snapped in instantly after CONTINUE | `presentCurrentCase(animated: true)` — 0.25s doc fade |
| 9 | Tutorial never shown for Ch1 case 0 | `showTutorialHint()` fires once on first case |

---

## PARTIALLY FIXED

**P2 — Text size multiplier coverage**  
Applied to: DeskScene message/audit, DocumentNode, MainMenuScene, ChapterSelectScene cells.  
NOT applied to: SettingsScene labels, DialogueScene, EndingScene body text, CreditsScene, ChapterSelectScene scene-level headers. A full pass on these scenes would require threading `textSizeMultiplier` through every `buildScene()` call.

**P2 — Document formatting overlap (PMCAQ)**  
DocumentNode layout code is correct (`keyColW = 130pt`, row height uses `max(keyLines, valLines)`). Visual confirmation on simulator shows Death Certificate and Redacted Sender File rendering without visible overlap. However, edge cases with very long field values may still overflow; not exhaustively tested across all 5×4=20 Ch1 documents.

**P4 — Transitions polish**  
Implemented: menu button press feedback, pause overlay fade, case-to-case fade, continue button fade-in, audit overlay fade (0.15s), document tab cross-fade (0.07s, already present).  
Not implemented: scene-level menu transition enhancement beyond existing 0.35s SceneManager fade, ChapterComplete scene transition polish, PlatformScene transition.

---

## NOT FIXED

**P2 — Full visual audit of Dialogue scene**  
DialogueScene font sizes were not audited or modified. No simulator screenshot captured of the dialogue scene.

**P5 — Text size affects Dialogue and Settings scene labels**  
DialogueScene and SettingsScene labels are fixed-size. Implementing requires threading `textSizeMultiplier` through those scenes' `buildScene()` calls.

---

## NEW ISSUES DISCOVERED

**1. Message panel bottom-edge density when audit response is long**  
When an action has a long `auditResponse`, the 90pt panel height leaves the result text very close to the bottom edge. Text is readable but compact. Consider increasing `totalHeight` from 90pt to 110pt for audit-response cases, or applying a small bottom padding.

**2. Ch3 `intro_ch3.json` nodes n1/n2 never fire**  
DeskScene has no hook to trigger mid-chapter or post-desk dialogue nodes. Nodes n1/n2 in `intro_ch3.json` are scaffolded but dead. Not a regression — was pre-existing scaffolding.

**3. ChapterSelect "completed" detection is prefix-based**  
`completedCaseIDs.contains(where: { $0.hasPrefix(chapter.id) })` — correct for current chapters but fragile if future chapter IDs share prefixes (e.g., "ch1" and "ch10").

**4. `--skip-to-desk` debug argument added to BootScene**  
This was added to enable simulator visual validation in this session. It should remain for future testing but should not affect production behaviour (it only fires when the argument is explicitly passed; `simctl launch` without the argument is the production path).

---

## RECOMMENDED NEXT STEPS

**Immediate (one session):**
1. Increase message panel `totalHeight` from 90 → 110pt for audit-response cases (5 min fix)
2. Add `textSizeMultiplier` to DialogueScene and SettingsScene

**Next content milestone:**
3. Author `cases_ch4.json`, `intro_ch4.json`, `level_ch4.json` — Ch4 is next in progression, now handled gracefully by ending loop fix
4. Wire `intro_ch3.json` n1/n2 dialogue hooks in DeskScene (mid-chapter and post-desk triggers)

**Polish (dedicated pass):**
5. ChapterComplete scene transition — currently uses default 0.35s fade; a brief typewriter reveal would fit the tone
6. DialogueScene readability audit + textSizeMultiplier

---

## VISUAL VALIDATION SUMMARY

| Screen | Device | Confirmed |
|---|---|---|
| BootScene | iPad Pro 11-inch sim | Title, subtitle, status typewriter ✅ |
| MainMenuScene | iPhone 17 sim landscape | Title, background, CRT, all 5 buttons ✅ |
| DeskScene Ch1 C01 | iPhone 17 sim landscape | Document tabs, fields, suspicious highlighting, action buttons, anomaly panel, HUD ✅ |
| DeskScene Ch1 C05 | iPhone 17 sim landscape | REDACTED document, ARCHIVED/APPROVED/FORWARDED actions, audit response message ✅ |

**Scene layout at runtime:** 874×402pts total; safe area insets left=62, right=62, bottom=20 (Dynamic Island + home indicator on iPhone 17); usable content area: 750×374pts.
