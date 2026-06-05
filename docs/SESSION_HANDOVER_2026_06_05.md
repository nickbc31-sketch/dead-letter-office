# Session Handover — 2026-06-05

**Dead Letter Office** | End-of-session reference  
**Purpose:** Resume work without re-discovering state. Read this first when returning to the project.

---

## Current branch

**`cursor/restore-platform-ch1`** — up to date with `origin/cursor/restore-platform-ch1`.

Base branch for PRs: **`main`**.

---

## Latest commits

| Commit | Message |
|--------|---------|
| `d1eb24a` | Add Phase 0 QA debug scene and canonical asset production docs. |
| `1ad902e` | Add platform action buttons, EMP stun, and dynamic thumbstick controls. |
| `6c9dc34` | Align drone detection with visible cone and restart level on catch. |
| `3d494e1` | Fix diagonal moving jump and restore reliable platform jump physics. |
| `11c776f` | Restore Chapter 1 PlatformScene after jump-debug regressions. |

---

## Working systems

All functional and must not be regressed without explicit intent.

### Scenes
Boot, MainMenu, Settings, ChapterSelect, Desk, Dialogue, Platform, ChapterComplete, Ending, Credits — plus **DebugScene** (`--start-at-debug` launch arg).

### Core gameplay
- JSON-driven cases, dialogue, levels, chapters (`chapters.json` defines Ch1–8 structure)
- Stamp actions (6 verbs), consequence scores, flags, save/load
- Three endings (Broadcast / Control / Erasure) via score comparison
- Accessibility: reduced flashing, text size, subtitles

### Platform (Ch1 + framework)
- Dynamic **8-way thumbstick** (lower-left, hidden until touch)
- Right cluster: **Interact (E)**, **EMP**, **Jump (↑)**
- Walk, double jump, crouch, interactables, pickups, patrol drones
- EMP stun: 300 px range, 8 s stun, `canSee` disabled while stunned
- `isMultipleTouchEnabled = true` on `GameViewController` (thumbstick + jump multitouch)

### Desk UI (verify in playtest — code present)
- Contradiction summary + **AUDIT LOG** overlay (`DeskScene.showContradictionSummary`)
- Suspicious field amber highlight + `◆` marker (`DocumentNode`)
- Note: `docs/PROJECT_STATUS_JUNE_2026.md` §5 still lists these as missing — **that section is stale**; trust the code.

### QA
- **DebugScene:** reset save, status panel (scores/flags), scene jumps (menu, chapter select, desk/platform ch1–3, intro ch1, ending broadcast), flag toggles, unlock all chapters

### Build
- iOS Simulator (iPhone 17): **BUILD SUCCEEDED** as of last session
- **Audio:** all call sites wired; **0 audio files** in bundle (silent fail, no crashes)

### Content shipped
- **Chapter 1** end-to-end playable (`cases_ch1`, `intro_ch1`, `level_ch1`)
- Ch2–3 level JSON exists locally; **no case/dialogue content** for Ch2–8
- Overall product ~15–20% complete; Ch1 ~80%

---

## Completed phases

| Phase | Status | Notes |
|-------|--------|-------|
| **Platform framework** | ✅ Complete | Walk, jump, drones, interactables, EMP, thumbstick |
| **Platform controls Phase B** | ✅ Complete | Right action cluster (Interact / EMP / Jump) |
| **Platform controls Phase C** | ✅ Complete | Dynamic disappearing thumbstick replaces left d-pad |
| **Ch4–8 blueprint (planning)** | ✅ Approved | Constraints locked in Phase 0.5 audit doc |
| **Phase 0.5 Full Asset Audit** | ✅ Approved | Committed `docs/design/Phase0.5_FullAssetAudit_June2026.md` |
| **Phase 0.6 Global Asset Production Pack** | ✅ Complete | Committed `docs/Phase0.6_GlobalAssetProductionPack.md` |
| **Phase 0 DebugScene** | ✅ Complete | Committed; launch `--start-at-debug` |
| **Chapter 4 engineering** | ⛔ Not started | Gated on Phase A assets + explicit approval |
| **Phase A asset production** | ⏳ Not started | Audio Session 1 + desk/parallax decisions |

---

## Approved blueprint status

**Chapters 4–8 production blueprint** approved in session (planning only — no dedicated file; constraints canonised in Phase 0.5 audit).

### Locked blueprint constraints
- Platform sections: **3–5 minutes maximum** per level
- **P06 train scope reduced** (2 carriages + siding)
- **Ch7 = most dialogue-heavy** chapter
- **Ch8 climax = desk C24 stamp** — not platform; P08 is infiltration/setup only (~3,000–3,500 pt)

### Chapter structure (`chapters.json`)
- Ch1–4: desk + platform segments
- Ch5: desk only (no platform segment in JSON yet)
- Ch6: platform only (train)
- Ch7: desk + platform (minimal)
- Ch8: desk only (C24 climax)

### First Ch4 engineering slice (when approved)
1. C13 stamp-lock (`DeskScene`)
2. Ladder climb (`MaraPlayerNode` + ladder interactable)
3. Ghost Audit scanner zones
4. Content: `cases_ch4.json`, `intro_ch4.json`, `level_ch4.json`
5. Wire `ambient_desk_tense.mp3`, scanner/EMP SFX

---

## Asset audit status

**Document:** `docs/design/Phase0.5_FullAssetAudit_June2026.md`  
**Status:** Approved 2026-06-05

### Summary
| Category | State |
|----------|-------|
| Portraits | 6/7 in catalog; **`portrait_elias_venn` must create** |
| Locked portraits | Mara, Calyx, Saint Orra, PMCA Director — do not regenerate |
| Full-screen backgrounds | `bg_desk_office` must create; `bg_main_menu`, `bg_terminal_wallpaper` in catalog |
| Platform parallax | Global trio procedural OK; **`bg_housing_mid/near`** must create (Ch3 JSON references) |
| Audio | **0 files** in bundle; all P0 tracks missing |
| AppIcon | In catalog |

### Ch4 asset gate (from audit)
- [ ] Session 1 audio (`ambient_desk`, `stamp`, `page_turn`, `ambient_platform`, `ambient_menu`)
- [ ] Desk background decision: `bg_terminal_wallpaper` vs `bg_desk_office`
- [ ] Parallax: procedural v1 OK **or** PL-001–003 batch
- [ ] `ambient_desk_tense` + EMP/drone/scanner SFX
- [x] Phase 0.5 audit approved
- [x] Phase 0 DebugScene complete

---

## Global Asset Production Pack status

**Document:** `docs/Phase0.6_GlobalAssetProductionPack.md`  
**Status:** Approved 2026-06-05 — documentation only, committed and pushed.

### What it provides
- Every **P0/P1** asset: name, purpose, dimensions, folder path, placeholder, production method, priority
- ComfyUI prompts, negative prompts, model/resolution/batch guidance for all visuals
- Portrait canon notes; parallax layer specs; Epidemic Sound search terms for all audio
- **Production Order:** Phase A (Ch4 gate) → B (global) → C (chapter-specific) → D (polish)

### Recommended first production batch (Phase A)
1. Epidemic Sound Session 1: `ambient_desk`, `ambient_menu`, `ambient_platform`, `stamp`, `page_turn`
2. Desk art decision + optional `bg_desk_office` generation
3. Parallax decision (procedural v1 vs global trio)
4. Ch4 audio/SFX: `ambient_desk_tense`, `sfx_emp_pulse`, `drone_alert`, `sfx_scanner_flag`, `terminal_beep`

---

## Current project risks

| Risk | Severity | Detail |
|------|----------|--------|
| **Silent game** | High | No audio in bundle; desk/platform feel unfinished despite working code |
| **Ch4 started before assets** | High | Engineering without Phase A audio/art produces untestable Ch4 |
| **Jump/movement regression** | High | `MaraPlayerNode` jump physics and multitouch are fragile — easy to break |
| **Stale PROJECT_STATUS** | Medium | §5 contradiction/suspicious-field gaps are outdated; §1 still says Ch2–8 have zero level data (ch2/ch3 JSON exist locally, uncommitted) |
| **Portrait gaps** | Medium | `portrait_elias_venn` missing; Jun Vale in catalog but not wired to dialogue |
| **iOS 26 fullscreen** | Medium | AppDelegate window hack works in simulator; unverified on physical device |
| **Uncommitted local edits** | Low | AppIcon, `level_ch2/ch3` spawn tweaks, `Info.plist` v2 — see below |
| **Runtime far below target** | Ongoing | ~35 min vs 3 hr target; content depth expansion still required |

---

## Recommended next task when you return

**Choose one path — do not mix without intent:**

### Path 1 — Asset production (recommended before code)
Execute **Phase A** from `docs/Phase0.6_GlobalAssetProductionPack.md`:
1. Source Epidemic Sound Session 1 (five files)
2. Decide desk background (`bg_terminal_wallpaper` interim vs generate `bg_desk_office`)
3. Decide parallax (keep procedural v1 for Ch4 start, or batch global trio)
4. Source Ch4 tension audio + platform SFX

When Phase A exit criteria are met → explicitly approve **Chapter 4 engineering**.

### Path 2 — Art generation session
ComfyUI Session 1 from production pack: `portrait_elias_venn` (img2img from Mara at 0.20) + optional `bg_desk_office` or parallax trio.

### Path 3 — Housekeeping (low priority)
- Commit or discard unstaged local files (see below)
- Update `docs/PROJECT_STATUS_JUNE_2026.md` §5 to reflect contradiction UI + DebugScene accurately
- Add `docs/Phase0.6_GlobalAssetProductionPack.md` to PROJECT_STATUS doc index

**Do not start Chapter 4 Swift implementation** until Phase A assets are in place and you explicitly green-light engineering.

---

## Local uncommitted files (exclude from blind commits)

These exist on disk but were **intentionally excluded** from commit `d1eb24a`:

| File | Notes |
|------|-------|
| `DeadLetterOffice/Assets.xcassets/AppIcon.appiconset/Contents.json` | AppIcon wiring |
| `DeadLetterOffice/Assets.xcassets/AppIcon.appiconset/AppIcon.png` | Untracked |
| `Assets/assets/AppIcon/` | Untracked |
| `DeadLetterOffice/Data/Levels/level_ch2.json` | Spawn Y 60→90 |
| `DeadLetterOffice/Data/Levels/level_ch3.json` | Spawn Y 60→90 |
| `DeadLetterOffice/Info.plist` | CFBundleVersion 1→2 |
| `ReviewShots/*.png` | Screenshots only |

Review before committing — may be WIP or device-specific.

---

## Files that should not be modified

### Locked canon — do not regenerate or redesign
| Asset / doc | Reason |
|-------------|--------|
| `assets/assets/Portraits/Approved/mara_venn_v1_approved.png` | Locked protagonist portrait |
| `assets/assets/Portraits/Approved/calyx_v1_approved.png` | Locked antagonist portrait |
| `assets/assets/Portraits/Approved/saint_orra_v1_approved.png` | Locked |
| `assets/assets/Portraits/Approved/pmca_director_v1_approved.png` | Locked |
| `portrait_mara`, `portrait_calyx`, `portrait_saint_orra`, `portrait_pmca_director` imagesets | Same — catalog mirrors approved files |
| `docs/CANON.md` locked names | World, characters, action verbs, structure |

### Platform physics — modify only with extreme care
| File | Reason |
|------|--------|
| `DeadLetterOffice/Platform/MaraPlayerNode.swift` | Manual jump, `friction = 0`, floor-edge fix — regressions broke Ch1 repeatedly |
| `DeadLetterOffice/GameViewController.swift` | `isMultipleTouchEnabled = true` required for thumbstick + jump |
| `DeadLetterOffice/Platform/DroneEnemyNode.swift` | Separate `stunTimer` / `isStunned`; do not conflate with patrol pause |

### Authority docs — change only via explicit design decision
| Document | Role |
|----------|------|
| `docs/CANON.md` | Highest authority |
| `docs/ArtStyleGuide.md` | Visual standard |
| `docs/design/Phase0.5_FullAssetAudit_June2026.md` | Approved audit + blueprint constraints |
| `docs/Phase0.6_GlobalAssetProductionPack.md` | Approved production roadmap |

### Schemas — do not break Ch1 compatibility
| Pattern | Rule |
|---------|------|
| `cases_ch*.json`, `intro_ch*.json`, `level_ch*.json` | Same Codable schemas as Ch1; content expansion is data-first |
| `chapters.json` segment structure | Align new chapters to existing segment modes |

---

## Key document index

| Document | Path |
|----------|------|
| This handover | `docs/SESSION_HANDOVER_2026_06_05.md` |
| Project status (read first — partially stale) | `docs/PROJECT_STATUS_JUNE_2026.md` |
| Phase 0.5 Asset Audit | `docs/design/Phase0.5_FullAssetAudit_June2026.md` |
| Phase 0.6 Production Pack | `docs/Phase0.6_GlobalAssetProductionPack.md` |
| Art pipeline | `docs/ArtStyleGuide.md`, `docs/AssetProductionPlan.md` |
| Audio sourcing | `docs/design/AudioProductionPlan.md` |
| Canon | `docs/CANON.md` |

### Debug launch
Xcode → Scheme → Run → Arguments → add `--start-at-debug`

---

*Handover written 2026-06-05. Branch `cursor/restore-platform-ch1` @ `d1eb24a`.*
