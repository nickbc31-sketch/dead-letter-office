# Dead Letter Office — Project Status
**Last updated:** 2026-06-02
**Purpose:** Source of truth for future sessions. Read this first before any work.

---

## 1. Current Build Status

| Item | State |
|---|---|
| Platform | iOS 26, iPhone 17 Pro Max simulator |
| Display | Full-screen landscape, 956 × 440 pt (logical) |
| Chapter 1 | Fully playable end-to-end |
| Chapters 2–8 | No content — zero case data, dialogue, or platform levels |
| Overall completion | ~15–20% of final product |
| Chapter 1 completion | ~80% (art, audio, and contradiction UI are the gaps) |
| Estimated full-game runtime (current density) | ~35 min normal player — well below target |
| Target runtime | 3 hours per route (normal player, one playthrough) |

The game is a working vertical slice. Chapter 1 is the milestone. Everything beyond Ch1 is unbuilt.

---

## 2. Working Systems

All of the following are implemented, tested, and must not be regressed.

### Scenes (all functional)
- **BootScene** — typewriter animation, transitions to MainMenu
- **MainMenuScene** — two-column landscape layout, all buttons functional
- **SettingsScene** — music vol, SFX vol, reduced flashing, text size, subtitles
- **ChapterSelectScene** — 8-chapter grid, unlock logic, back button
- **DeskScene** — document viewer, tabs (up to 4), stamp actions, HUD bars, pause menu
- **DialogueScene** — portrait frame, text box, advance logic, choices, exit button
- **PlatformScene** — walk, jump (double), crouch/hide, patrol enemies, interactables, pickups
- **ChapterCompleteScene** — functional, transitions correctly
- **EndingScene** — 3 endings wired (Broadcast/Control/Erasure), determined by score comparison
- **CreditsScene** — basic credits functional

### Core Systems
- **SceneManager / SceneRouter** — all transitions, scaleMode, view injection
- **GameState / GameStateManager** — 6 score variables (compliance, suspicion, empathy, resistance trust, corporate trust, grief index), flags, decisions, accessibility settings
- **SaveManager** — Codable, UserDefaults, hasSave check; round-trip verified
- **Flag system** — flagsSet / flagsCleared per action; flagsRequired gating on dialogue nodes and chapters
- **Consequence tracking** — 6 score variables, flags, caseDecisions recorded per case
- **Stamp actions** — Approve, Reject, Censor, Archive, Flag Anomaly, Illegal Forward — all functional
- **Audit response + result text** — auditResponse and resultText shown correctly after stamp
- **Chapter completion + unlock** — ch[N]_chapter_complete flag, ChapterSelectScene unlock logic
- **Three endings** — Broadcast / Control / Erasure determined by accumulated score comparison in DeskScene.determineEnding()
- **Accessibility** — reduced flashing (CRTEffectNode checks flag), text size multiplier, subtitles default-on
- **CRT effect** — CRTEffectNode correctly overlaid on portrait frames; scanline overlay working

### Platform Mechanics (Ch1 level)
- Walk / run, double jump, crouch (reduces hitbox and speed)
- Interact (proximity button, flags set/read)
- Patrol enemies (3 drones, patrol points, pause, basic proximity detection)
- Environmental text signs (display on interact)
- Data cartridge pickups (set flags on collection)

### Data Models (all Codable)
CaseFile, CaseDocument (DocumentModel), Contradiction, CaseAction, ConsequenceMap, DocumentField, Stamp, DialogueNode/Line, PlatformLevel (LevelData), Interactable, PatrolRoute, ChapterDefinition (ChapterData), SaveData — all complete and JSON-driven.

---

## 3. Completed Systems (Chapter 1 content)

| Asset | Status |
|---|---|
| `cases_ch1.json` — 5 cases (C01–C05) | Complete |
| `intro_ch1.json` — 11 lines, 3 nodes, linear | Complete |
| `level_ch1.json` — P01 Archive Walk, 3000 pt, 3 drones, 6 interactables | Complete |
| `chapters.json` — 8 chapters defined with unlock logic | Complete |
| UITest suite — 3 passing tests in DeskInteractionTests.swift | Complete |

### Ch1 Story Beats Implemented
- Opening shift: Audit Voice greeting
- Director Calyx orientation speech
- Mara questions the system
- C01 Olen Marr — timestamp contradiction
- C02 Mira Sol — living recipient contradiction
- C03 Tovin Kade — forged Helix seal
- C04 Nella Voss — Elias routing tag (personal stakes introduced)
- C05 Unknown Sender — "I AM NOT DEAD" glitch animation
- P01 Archive Walk — basic level functional
- Ch1 completion → ChapterCompleteScene → three endings reachable

---

## 4. Approved Portraits

| Portrait | Asset catalog name | Approved file | Status |
|---|---|---|---|
| Mara Venn | `portrait_mara` | `mara_venn_v1_approved.png` | ✅ In Assets.car — **do not regenerate** |
| Director Calyx | `portrait_calyx` | `calyx_v1_approved.png` | ✅ In Assets.car — **do not regenerate** |
| Saint Orra | `portrait_saint_orra` | `saint_orra_v1_approved.png` | ✅ In Assets.car — **do not regenerate** |
| PMCA Director | `portrait_pmca_director` | `pmca_director_v1_approved.png` | ✅ In Assets.car — **do not regenerate** |
| Jun Vale | `portrait_jun_vale` | `portrait_jun_vale` (separate file) | ⚠️ In Assets.car but not wired to any dialogue; pending formal v1 confirmation |
| The Audit Voice | `portrait_audit_voice` | — | ❌ Missing — geometric amber-slit mask; non-human |
| Elias Venn | `portrait_elias_venn` | — | ❌ Missing — img2img from `portrait_mara` at 0.20 strength |

**Portrait visual notes (locked — do not deviate):**
- Mara: East Asian woman, late twenties, dark updo, PMCA uniform, blue-grey background
- Calyx: East Asian man, late thirties, dark suit/tie, near-frontal, more dramatic shadow contrast than Mara
- PMCA Director: older man, grey hair, moustache, heavyset — distinct from Calyx
- Audit Voice: featureless dark obsidian mask, single amber horizontal slit, no face
- Elias: sibling resemblance to Mara, ghostly quality (~85% opacity after post-processing)
- Lighting rule (all portraits): teal from upper-left, amber from upper-right
- Style authority: `docs/Art/PortraitStyleReference.md` — consult before generating any portrait

---

## 5. Outstanding Bugs and Gaps

### Critical (blocks player understanding of core mechanic)
| Bug | Detail |
|---|---|
| **Contradiction panel not shown to player** | Contradiction model and data exist in JSON but DeskScene/DocumentNode never surfaces it in UI. The game's core pillar is "compare contradictions" — this is invisible. |
| **Suspicious field highlighting missing** | `isSuspicious` flag exists in DocumentField model and is populated in JSON, but DeskScene renders all fields identically. Player cannot identify which fields to scrutinise. |

### High Priority (needed before Ch2 build begins)
| Gap | Detail |
|---|---|
| **Document zoom / expand missing** | Documents are fixed-size in DeskScene. Bible Section 13 specifies zoomable/expandable documents. Hard to read on smaller phones. |
| **DebugScene / debug menu missing** | Bible specifies: reset save, load each case, inspect flags, set variables, jump scene. Essential for QA during Ch2–8 development. |
| **EvidenceScene missing** | Dedicated scene for reviewing platform-found evidence. Required for Ch5+ when physical evidence changes desk decisions. |

### Medium Priority
| Gap | Detail |
|---|---|
| **Climb mechanic (ladders) missing** | `ladder` interactable type exists in data model; MaraPlayerNode has no climb state. Required for P04+ levels. |
| **True stealth / detection system** | Drones detect proximity only. No vision cone. Crouch reduces hitbox but does not trigger stealth evasion logic. |
| **Jun Vale portrait not wired** | Approved portrait is in catalog but not referenced in any dialogue JSON. |
| **UITest coordinate system** | Tests use hardcoded tap coordinates from the old 480×320 canvas. May need updating for 956×440 layout. |

### Low Priority (deferred to Phase 7–8)
| Gap | Detail |
|---|---|
| Stun pulse mechanic | Optional platform mechanic; deferred until platform levels exist |
| Platform assist (skip on failure) | Accessibility feature; deferred |
| EndingDefinition model | Endings currently hardcoded in DeskScene.determineEnding(); functional but not JSON-driven |
| ConsequenceManager as separate class | Currently inline in DeskScene/GameState; couples consequence logic to scene code; refactor when Ch2+ adds new consequence types |
| Replay mode flag | Chapter Select replay re-shows completed cases but DeskScene filters them by completion ID; need `GameState.isReplayMode` for replay paths |
| Dialogue scene upper-right void | Background fills canvas but upper-right area is visually empty during dialogue scenes |

### Architecture / Technical Debt
- **iOS 26 fullscreen mechanism:** Current fix removes UIApplicationSceneManifest from Info.plist entirely and creates the window in AppDelegate. Works in simulator. Must be verified on a physical iOS 26 device before App Store submission. UIRequiresFullScreen in Info.plist alone does not work in the simulator build.
- **AudioManager wired but silent:** All audio call sites exist. All 10 audio files are missing from the bundle (silent fail — no crashes).

---

## 6. Bible Location

| Document | Path | Authority |
|---|---|---|
| **Project Bible v4.0** (master spec) | `docs/Dead_Letter_Office_Definitive_Project_Bible_v4_FULL.docx` | Sections 1–14 cover all story, cases, mechanics, audio, App Store |
| **CANON.md** (locked world names, characters) | `docs/CANON.md` | Supersedes all other docs on naming and core concept |
| **ArtStyleGuide.md** | `docs/ArtStyleGuide.md` | Locks visual standard and post-processing pipeline |
| **PortraitStyleReference.md** | `docs/Art/PortraitStyleReference.md` | Supersedes ArtStyleGuide on portrait specifics — derived from the 4 approved portraits |
| **ApprovedPortraitSettings.md** | `docs/Art/ApprovedPortraitSettings.md` | Records generation seeds/settings for approved portraits |

**Document authority order (highest to lowest):**
1. `CANON.md`
2. `ArtStyleGuide.md`
3. `docs/Art/PortraitStyleReference.md`
4. `docs/Art/ApprovedPortraitSettings.md`
5. Project Bible v4.0
6. `AssetProductionPlan.md`
7. `PLACEHOLDER_POLICY.md`
8. All other documentation and code

---

## 7. Art Pipeline

**Tool:** DiffusionBee + DreamShaper XL Turbo (primary model for all assets — do not substitute)
**Post-processing:** Pixelmator (posterize → palette correct → contrast boost)
**Import:** Xcode Assets.xcassets, 2x slot

### Asset Status Summary

| Category | Required | In catalog | Missing |
|---|---|---|---|
| Character portraits | 7 | 5 (4 approved + Jun Vale unconfirmed) | portrait_audit_voice, portrait_elias_venn |
| Scene backgrounds | 9 | 0 | All (bg_desk_office, bg_main_menu, bg_chapter_complete, 3 × endings, bg_boot_screen) |
| Platform parallax layers | 3 | 0 | bg_city_far, bg_facility_mid, bg_facility_near |
| Player/enemy sprites | 2 | 0 | mara_silhouette, sprite_security_drone |
| Stamp/UI icons | 8 | 0 | All 6 stamp icons + 2 pickup icons |
| Document paper texture | 1 | 0 | texture_document_paper |
| Chapter splash screens | 8 | 0 | splash_ch1–splash_ch8 (T3, deferred) |

### Generation Priority Order
1. `portrait_audit_voice` (P-002) — T1, needed for any Ch1 dialogue polish
2. `portrait_elias_venn` (P-006) — T2, use portrait_mara as img2img at 0.20 strength
3. `bg_desk_office` (BG-001) — T1, visible throughout entire game
4. `bg_main_menu` (BG-002) — T1, first impression
5. `bg_city_far` (PL-001) — T1, 6144 × 800 px strip, same seed family as PL-002 and PL-003
6. `bg_facility_mid` (PL-002) — T1, same seed session as PL-001
7. `bg_facility_near` (PL-003) — T1, PNG with alpha, upper 50% transparent
8. `mara_silhouette` (CH-001) — T1, 128 × 192 px, nearest-neighbour scaling only
9. Stamp icons UI-001–006 — T2
10. Remaining backgrounds (chapter_complete, 3 × endings, boot screen) — T2/T3

### Asset File Naming Contract (never deviate)
All portrait `portraitAsset` values in dialogue JSON must exactly match asset catalog imageset names:

| JSON value | Imageset name |
|---|---|
| `portrait_mara` | `portrait_mara` |
| `portrait_calyx` | `portrait_calyx` |
| `portrait_audit_voice` | `portrait_audit_voice` |
| `portrait_jun_vale` | `portrait_jun_vale` |
| `portrait_saint_orra` | `portrait_saint_orra` |
| `portrait_pmca_director` | `portrait_pmca_director` |
| `portrait_elias_venn` | `portrait_elias_venn` |

### Global Style Lock (paste into every DiffusionBee prompt)
```
DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos
```

---

## 8. Audio Plan

AudioManager is fully implemented and wired. All scenes call `AudioManager.playMusic()` and `sfxAction()` at the correct moments. The manager fails silently when files are absent — no crashes. Drop files into the Xcode bundle and they work immediately with no code changes.

### Music Loops (6 required)

| File | Scene | Mood | Duration |
|---|---|---|---|
| `ambient_boot.mp3` | BootScene | Single-tone drone | 30 s loop |
| `ambient_mainmenu.mp3` | MainMenuScene | Slow ambient, melancholic | 60 s loop |
| `ambient_desk.mp3` | DeskScene | Office hum, paper rustle | 60 s loop |
| `ambient_platform.mp3` | PlatformScene | Industrial tension | 60 s loop |
| `chapter_complete.mp3` | ChapterCompleteScene | Melancholic swell | 20 s one-shot |
| `ambient_ending.mp3` | EndingScene | All 3 endings share this | 60 s loop |

### Sound Effects (4 required)

| File | Trigger | Duration |
|---|---|---|
| `sfx_stamp.mp3` | Stamp action in DeskScene | 0.5 s |
| `sfx_page_turn.mp3` | Document tab switch | 0.3 s |
| `sfx_terminal_beep.mp3` | Terminal interactions in PlatformScene | 0.2 s |
| `sfx_drone_alert.mp3` | Drone detection | 0.8 s |

**Notable Bible-specified SFX gap:** `glitch_im_not_dead.wav` — named in Bible Section 10 for the C05 glitch animation. The animation plays visually but is silent. Add this SFX when audio production begins.

**Status: 0/10 audio files exist in the bundle.**

---

## 9. Runtime Analysis Status

### Current Ch1 measured timings (from code constants and JSON)

| Player type | Ch1 time | Notes |
|---|---|---|
| Speedrun | ~1:40 | No reading, instant decisions, skips everything |
| Normal | ~5 min | Reads contradiction panel, considers options ~8s, engages most interactables |
| Thorough | ~15–16 min | Reads all body text at 80 wpm, re-reads cross-references, 15s+ per decision |

### Full-game projection at Ch1 density (before expansion)

| Player type | 8-chapter total |
|---|---|
| Speedrun | ~9.4 min |
| Normal | ~35.4 min |
| Thorough | ~90.6 min |

**This is the problem.** 35 minutes for a premium game is not viable.

### Target runtimes (from ContentExpansionPlan.md)

| Chapter | Cases | Docs | Contradictions | Platform | Target (normal) |
|---|---|---|---|---|---|
| 1 — Orientation | 5 | 30 | 9 | 5,000 pt | 20–25 min |
| 2 — Misfiled Living | 3 | 18 | 7 | 6,000 pt | 25–28 min |
| 3 — Daughter Clause | 3 | 18 | 7 | 5,500 pt | 25–28 min |
| 4 — Ghost Audit | 3 | 17 | 6 | 6,500 pt | 26–29 min |
| 5 — Afterlife Premium | 3 | 18 | 7 | 5,000 pt | 24–27 min |
| 6 — Black Mail Train | 3 | 18 | 7 | 8,000 pt | 28–32 min |
| 7 — Choir Beneath | 3 | 19 | 7 | 6,000 pt | 27–30 min |
| 8 — Dead Letter Office | 1 | 8 | 3 | 10,000 pt | 25–30 min |
| **TOTAL** | **24** | **146** | **53** | **52,000 pt** | **~3h 20min** |

**The solution:** Deeper chapters, not more chapters. The JSON infrastructure supports arbitrary content depth without code changes. Runtime is gained through: richer body text (100 → 200–250 words per document), 2–3 contradictions per case instead of 1, PMCA queue instruction documents on every case, 3 dialogue events per chapter instead of 1, and platform levels at 5,000–10,000 pt instead of 3,000 pt.

### Source documents
- `docs/design/Chapter1RuntimeAnalysis.md` — full timing model and methodology
- `docs/design/ContentExpansionPlan.md` — complete expansion plan with all 24 case designs, per-chapter summary tables, platform level specs, dialogue events, and recurring narrative thread tracking

---

## 10. Next Recommended Tasks

Listed in priority order. Do not skip phases.

### Immediate (Phase 1 — lock Ch1 vertical slice)

1. **Wire portrait_jun_vale** — File is in Assets.car but not referenced in any dialogue JSON. Add to `intro_ch1.json` or any post-Ch1 dialogue node where Jun Vale appears.

2. **Expose contradiction UI in DeskScene** — The Contradiction model is populated in `cases_ch1.json`. DeskScene/DocumentNode must surface it to the player. This is the most critical missing mechanic — the game's core design pillar is "compare contradictions."

3. **Expose suspicious field highlighting** — `isSuspicious: true` fields in DocumentField must render differently from normal fields (e.g., a `◆` marker or amber text). The data is there; the UI is not.

4. **Generate portrait_audit_voice** (P-002) — Geometric amber-slit mask, no face. See `AssetProductionPlan.md` for exact prompt and settings.

5. **Generate bg_desk_office** (BG-001) — T1, visible throughout entire game. Add to DeskScene as `SKSpriteNode` at `zPosition = -10`.

6. **Generate bg_main_menu** (BG-002) — T1, first impression.

7. **Add Ch1 post-desk dialogue node** — Add a node to `intro_ch1.json` gated by `ch1_chapter_complete` flag. Jun Vale's first contact — a message reaching Mara through the Dead Letter system. Sets tone for Ch2.

8. **Expand Ch1 document depth** — Add 2 documents per case (PMCA Queue Instruction + one case-specific additional document). Add secondary contradiction to each case. This alone adds ~5 minutes of normal-player content. See `ContentExpansionPlan.md` Ch1 section for exact specifications.

9. **Expand P01 from 3,000 → 5,000 pt** — Add locked terminal (C03 flag), 4 environmental signs, 1 optional dead-end room with the 12-name list. Detailed in ContentExpansionPlan.md.

### Short-term (Phase 2 — Chapter 2)

10. **Create cases_ch2.json** — C06 Garr Sen, C07 Alia Brent, C08 Courier 19. Full case designs with 6 documents each and 2–3 contradictions each are in ContentExpansionPlan.md.

11. **Create intro_ch2.json** — Pre-desk empathy assessment dialogue (Audit Voice + Mara), mid-chapter Jun Vale trace trigger (conditional on C06 Flag Anomaly), post-desk pre-loaded queue revelation.

12. **Create level_ch2.json** — P02 Sorting Centre, 6,000 × 500 pt, 5 drones, 12 interactables, drone detection cone (partial new mechanic: facing direction indicator).

13. **Build DebugScene** — Reset save, load case, inspect flags, set variables, jump scene. Critical for QA from Ch2 onward.

### Medium-term (Phase 3 — Chapters 3–5)

14. **Implement consequence flag callbacks** — C09 reads C01 decision flag from GameState. Test before Ch4 build begins.

15. **Implement climb mechanic** — `ladder` interactable type must trigger a climb state in MaraPlayerNode. Required for P04 Records Annex vent sections.

16. **Generate platform parallax layers** (PL-001, PL-002, PL-003) — Generate in one session using same seed family for visual coherence.

17. **Generate mara_silhouette** (CH-001) — 128 × 192 px, nearest-neighbour scaling only.

18. **Cases Ch3–Ch5** and associated dialogue and platform levels. All detailed in ContentExpansionPlan.md.

### Long-term (Phases 4–9)

- Chapters 6–8 content (C18–C24, intros, platform levels P06–P08)
- Timed door mechanic for P06 Black Mail Train
- C13 mechanic: stamp buttons locked until all 6 documents examined (small DeskScene code addition)
- Generate portrait_elias_venn (img2img from portrait_mara at 0.20 strength)
- All audio (10 files, AudioManager already wired)
- All stamp icons and remaining UI assets
- Full playthrough testing (all 3 endings)
- App Store preparation (icon, metadata, screenshots, TestFlight)

---

## 11. File Locations

### Content Data
| File | Path |
|---|---|
| Chapter 1 cases | `DLO/Data/Cases/cases_ch1.json` |
| Chapter 1 dialogue | `DLO/Data/Dialogues/intro_ch1.json` |
| Chapter 1 platform level | `DLO/Data/Levels/level_ch1.json` |
| Chapter definitions | `DLO/Data/chapters.json` |
| Chapters 2–8 | *Do not exist yet* |

### Documentation
| Document | Path |
|---|---|
| This file (source of truth) | `docs/PROJECT_STATUS_JUNE_2026.md` |
| Project Bible v4.0 | `docs/Dead_Letter_Office_Definitive_Project_Bible_v4_FULL.docx` |
| CANON.md | `docs/CANON.md` |
| Art Style Guide | `docs/ArtStyleGuide.md` |
| Portrait Style Reference | `docs/Art/PortraitStyleReference.md` |
| Approved Portrait Settings | `docs/Art/ApprovedPortraitSettings.md` |
| Asset Production Plan v4.0 | `docs/AssetProductionPlan.md` |
| Placeholder Policy | `docs/PLACEHOLDER_POLICY.md` |
| Bible Gap Analysis | `docs/design/BibleGapAnalysis.md` |
| Chapter 1 Runtime Analysis | `docs/design/Chapter1RuntimeAnalysis.md` |
| Content Expansion Plan | `docs/design/ContentExpansionPlan.md` |
| Full Game Production Roadmap | `docs/design/FullGameProductionRoadmap.md` |
| Audio Production Plan | `docs/design/AudioProductionPlan.md` |
| Contradiction System Audit | `docs/design/ContradictionSystemAudit.md` |

### Assets
| Asset type | Path |
|---|---|
| Approved portraits | `assets/assets/Portraits/Approved/` |
| Generated portraits (for review) | `assets/assets/Portraits/generated/` |
| Asset catalog | `DLO/Assets.xcassets/` |
| Reference image (Mara) | `docs/mararef.png` |

### Xcode Project
| Item | Path |
|---|---|
| Main project | `DLO/DLO.xcodeproj` |
| UITest suite | `DLO/DLOUITests/DeskInteractionTests.swift` |
| AppDelegate (fullscreen fix) | `DLO/AppDelegate.swift` |

---

## 12. Key Design Decisions

These decisions are locked unless explicitly revisited with a new entry in CANON.md.

### Structure
- **8 chapters, 24 cases (C01–C24), 8 platform levels (P01–P08), 3 endings**
- Endings: **Broadcast** (resist, citywide), **Control** (comply, system continues), **Erasure** (partial resistance, Mara erased from record)
- Ending determination: score comparison of resistanceTrust + empathyScore vs. complianceScore + corporateTrust accumulated across all 8 chapters
- Ch8 has 1 case only (C24) — the entire chapter is built around a single decision

### Action Verbs (locked — do not rename)
Approve, Reject, Censor, Archive, Flag Anomaly, Illegal Forward

### iOS / Technical
- **Full-screen fix:** AppDelegate creates UIWindow from UIScreen.main.bounds; UIApplicationSceneManifest removed from Info.plist. This bypasses UIWindowScene lifecycle. Must verify on real iOS 26 hardware before submission — UIRequiresFullScreen in Info.plist alone does not work in simulator.
- **Design canvas:** 956 × 440 pt logical (1912 × 880 px at @2x)
- **Scene touch system:** DeskScene uses CGRect-based touch detection at scene level, not `isUserInteractionEnabled` on child nodes — do not revert
- **Build-forward rule:** All chapters 2–8 must use the same JSON schemas as Ch1. No chapter-specific Swift code. Content expansion is a data task only, not an engineering task.
- **ConsequenceManager:** Currently inline in DeskScene/GameState. Acceptable until Ch2+ introduces new consequence types that require refactoring.

### Content / Narrative
- **Target runtime:** 3 hours per route (normal player, one playthrough); 6+ hours for thorough player or multi-route play
- **Runtime strategy:** Deepen existing chapters rather than add chapters. Infrastructure supports arbitrary document depth without code changes.
- **Per-case document target:** 6 documents (up from 4); 200–250 words body text (up from ~100); 2–3 contradictions (up from 1)
- **PMCA Queue Instruction:** Every case gets one auditLog-type document as the first tab — institutional framing that makes the player feel watched before they start reading
- **Tertiary contradictions:** Not surfaced in the contradiction panel; discoverable only through close reading of suspicious fields. This is deliberate — rewards careful players.
- **Consequence callbacks:** C09 documents change based on C01 decision; C12 changes based on C01+C09; these read flags from GameState. Test consequence flag reading before building Ch4.
- **C13 mechanic:** Stamp buttons locked until all 6 documents are examined (Mara must read her own scheduled death before deciding what to do). Requires a small DeskScene code addition.
- **The system is always ahead of Mara.** This is the thematic constant: pre-loaded queues, pre-signed forms, pre-submitted audits, death notices before causes. The timeline of institutional action always precedes the event it supposedly responds to.

### Art
- **Model:** DreamShaper XL Turbo — primary for all assets, no exceptions for portraits
- **Portrait consistency:** All portraits must be generated at CFG 2.5, Steps 10, Euler sampler, 1024 × 1024 canvas — same baseline so they share a rendering style
- **Approved portraits are locked:** Mara, Calyx, Saint Orra, PMCA Director. Do not regenerate. Reference `PortraitStyleReference.md` for matching any new portrait.
- **Calyx description update:** Early documentation described Calyx as a middle-aged man with grey slicked-back hair. The approved portrait is an East Asian man, late thirties, dark hair. The approved portrait is correct.
- **Nearest-neighbour scaling only** for sprites (mara_silhouette, sprite_security_drone) — no Lanczos or bilinear

### Premium / Commercial
- No IAP, no ads, no multiplayer, no server dependencies — ever
- Price: £2.99 / sale £1.99 (from Bible Section 1)
- Age rating: 12+ (mild narrative violence)
- English only at launch; strings not yet extracted to Localizable.strings (defer to post-launch)
- AI-generated art licence: confirm DreamShaper XL Turbo commercial use terms before App Store submission

---

*Created 2026-06-02. Synthesised from: Project Bible v4.0, CANON.md, BibleGapAnalysis.md, Chapter1RuntimeAnalysis.md, ContentExpansionPlan.md, FullGameProductionRoadmap.md, AssetProductionPlan.md, PortraitStyleReference.md. Update this file whenever a phase is completed or a locked decision changes.*
