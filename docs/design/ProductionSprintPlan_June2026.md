# Dead Letter Office — Production Sprint Plan
**Date:** 2026-06-02
**Role:** Lead Producer
**Sprint duration:** 14 days (2026-06-02 to 2026-06-16)
**Developer:** Solo
**Tools in use:** Claude Code, ChatGPT, Xcode, SpriteKit, DiffusionBee, ComfyUI, Epidemic Sound

---

## Executive Summary

The project is at a functional vertical slice for Chapter 1. The engine works. The content pipeline (JSON-driven cases, dialogue, platform levels) is validated and extensible without code changes. Chapter 1 is approximately 80% complete — the gap is art, audio, and two missing UI features that undermine the game's core mechanic.

**The single largest risk today:** the contradiction panel is never shown to the player. The game's central design pillar — "compare contradictions across documents" — is invisible. Players cannot do the thing the game is built around. This is not a polish issue. It is a structural gap that makes playtesting unreliable.

**The 14-day sprint goal:** Resolve the critical mechanic gaps, lock Chapter 1 to production density, complete Chapter 2, begin Chapter 3, and establish the content pipeline cadence that will carry the project through Chapters 3–8.

**Sprint definition of done:**
- Contradiction UI visible to player
- Suspicious field highlighting active
- Chapter 1 at 20–25 minute normal-player runtime
- Chapter 2 fully playable end-to-end
- Chapter 3 cases written and wired
- `portrait_audit_voice` generated and in catalog
- Background art: `bg_desk_office`, `bg_main_menu` in catalog
- Audio Session 1 sourced and imported

---

## Part 1: Complete Remaining Work Inventory

### 1.1 Narrative

| Task | Priority | Tool | Notes |
|---|---|---|---|
| Ch1 case enrichment: add PMCA Queue Instruction to each of C01–C05 | **Critical Path** | Claude Code | 5 new documents; content specified in ContentExpansionPlan.md |
| Ch1 case enrichment: add secondary contradiction to each of C01–C05 | **Critical Path** | Claude Code / ChatGPT | Second document per case; designs in ContentExpansionPlan.md |
| Ch1 case enrichment: increase body text 100→200 words per primary document | **Important** | Claude Code / ChatGPT | Doubles reading time per case |
| Ch1 dialogue: add post-desk node (Jun Vale first contact) | **Important** | Claude Code | Gated by `ch1_chapter_complete` flag |
| Expand P01 to 5,000 pt (level_ch1.json) | **Important** | Claude Code | 4 new interactables; 1 optional room; specifications in ContentExpansionPlan.md |
| Write cases_ch2.json — C06, C07, C08 | **Critical Path** | Claude Code / ChatGPT | Full designs in Ch2 Design Package Rev. 2 |
| Write intro_ch2.json — pre-desk, mid-chapter conditional, post-desk | **Critical Path** | Claude Code | Dialogue specified in Ch2 Design Package; requires portrait_audit_voice |
| Write level_ch2.json — P02 Sorting Centre | **Critical Path** | Claude Code | 12 interactables, 5 drones; full spec in Ch2 Design Package |
| Write cases_ch3.json — C09 (4 consequence variants), C10, C11 | **Important** | Claude Code / ChatGPT | C09 reads C01 decision flag; designs in ContentExpansionPlan.md |
| Write intro_ch3.json — Calyx memo pre-desk, mid-chapter cascade, post-desk | **Important** | Claude Code | Dialogue content specified in ContentExpansionPlan.md |
| Write level_ch3.json — P03 Lower Housing Block | **Important** | Claude Code | Terminal content varies by C01+C09 outcome flags |
| Write cases_ch4.json — C12, C13, C14 | **Nice To Have** (within sprint) | Claude Code / ChatGPT | C13 requires code support before full testing |
| Write intro_ch4.json | **Nice To Have** (within sprint) | Claude Code | — |
| Write level_ch4.json — P04 Records Annex | **Nice To Have** (within sprint) | Claude Code | Requires ladder mechanic implementation |
| Cases Ch5–Ch8 (C15–C24) | Post-sprint | Claude Code / ChatGPT | ContentExpansionPlan.md contains full designs |
| Intro dialogues Ch5–Ch8 | Post-sprint | Claude Code | — |
| Platform levels P05–P08 | Post-sprint | Claude Code | P06 requires new timed door code |

---

### 1.2 Programming

| Task | Priority | Notes |
|---|---|---|
| **Implement contradiction panel in DeskScene** | **Critical Path** | Game's core pillar currently invisible; Contradiction model + JSON data exist; UI just not rendered |
| **Implement suspicious field highlighting** | **Critical Path** | `isSuspicious` flag exists in model and JSON; DeskScene renders all fields identically; player cannot find clues |
| Wire portrait_audit_voice to asset catalog | **Critical Path** | File will exist once generated; one line of dialogue JSON naming it |
| Wire portrait_jun_vale to asset catalog | **Important** | File exists in catalog; not referenced in any dialogue JSON yet |
| Document zoom / expand in DeskScene | **Important** | Bible Section 13 specifies zoomable documents; needed for readability |
| Mid-chapter dialogue interrupt in DeskScene | **Important** | Required for Ch2's conditional routing anomaly trigger (n1); may require small new code path |
| Drone facing indicator in DroneEnemyNode | **Important** | Visual only — facing direction already tracked; adds arrow/cone sprite |
| Debug menu / DebugScene | **Important** | Essential for Ch2–8 QA; reset save, load case, inspect flags, jump scene |
| Ladder climb mechanic in MaraPlayerNode | **Important** | Required for P04 Records Annex; `ladder` interactable type exists in data model |
| C13 stamp-lock mechanic | **Important** | Stamp buttons locked until all 6 documents opened; Ch4 only |
| EvidenceScene | **Important** | Bible-specified; needed for Ch5+ platform-to-desk evidence carrying |
| Replay mode flag in GameState | **Nice To Have** | Chapter Select replay currently filters completed cases incorrectly |
| Stun pulse mechanic | **Nice To Have** | Optional platform mechanic; defer until after Ch4 |
| Platform assist / skip on failure | **Nice To Have** | Accessibility; defer until platform levels exist |
| EndingDefinition JSON model | **Nice To Have** | Currently hardcoded logic; functional but not data-driven |
| UITest suite expansion (3 new tests) | **Nice To Have** | Add after Ch2 content is stable |

---

### 1.3 Art

| Task | Priority | Tool | Notes |
|---|---|---|---|
| **Generate portrait_audit_voice** | **Critical Path** | DiffusionBee | Blocks ALL Ch2+ dialogue; geometric amber-slit mask; prompt in AssetProductionPlan.md P-002 |
| **Generate bg_desk_office** | **Critical Path** | DiffusionBee | T1; visible throughout entire game; prompt in AssetProductionPlan.md BG-001 |
| **Generate bg_main_menu** | **Critical Path** | DiffusionBee | T1; first impression; prompt in AssetProductionPlan.md BG-002 |
| Generate portrait_elias_venn | **Important** | DiffusionBee | img2img from portrait_mara at 0.20 strength; needed for Ch5–Ch8 |
| Generate platform parallax layers (PL-001, PL-002, PL-003) | **Important** | DiffusionBee / ComfyUI | Generate in single session, same seed family; 6144 × 800 px each |
| Generate mara_silhouette player sprite | **Important** | DiffusionBee | 128 × 192 px; nearest-neighbour scaling only |
| Generate sprite_security_drone | **Important** | DiffusionBee | T2; can use procedural placeholder longer than mara_silhouette |
| Generate bg_chapter_complete | **Important** | DiffusionBee | T2; ChapterCompleteScene currently black |
| Generate 3 × ending backgrounds | **Nice To Have** | DiffusionBee | T3; deferred; EndingScene functional with dark bg |
| Generate bg_boot_screen | **Nice To Have** | DiffusionBee | T3; BootScene is brief |
| Generate 6 stamp icons | **Nice To Have** | DiffusionBee | T2; buttons show text labels — readable but not polished |
| Generate 2 UI collectible icons | **Nice To Have** | DiffusionBee | T2 |
| Generate document paper texture | **Nice To Have** | DiffusionBee | T2; DocumentNode overlay |
| Generate 8 chapter splash screens | **Nice To Have** | DiffusionBee | T3; ChapterSelectScene shows text only; defer to Phase 5 |
| App icon (1024×1024) | **Important** | DiffusionBee | Required for App Store submission; not yet started |

---

### 1.4 Audio

| Task | Priority | Tool | Notes |
|---|---|---|---|
| **Source ambient_desk.mp3** | **Critical Path** | Epidemic Sound | Most important track; plays for majority of game runtime |
| **Source stamp.wav** | **Critical Path** | Epidemic Sound | Most frequent SFX; must not be annoying |
| **Source page_turn.wav** | **Critical Path** | Epidemic Sound | Fires on every document tab switch |
| **Source ambient_platform.mp3** | **Critical Path** | Epidemic Sound | Platform sections currently silent |
| Source ambient_mainmenu.mp3 | **Important** | Epidemic Sound | Main menu first impression |
| Source chapter_complete.mp3 | **Important** | Epidemic Sound | Chapter end stinger |
| Source terminal_beep.wav | **Important** | Epidemic Sound | Platform terminal interactions |
| Source drone_alert.wav | **Important** | Epidemic Sound | Drone detection |
| Source ambient_ending.mp3 | **Important** | Epidemic Sound | All three endings share one track |
| Source glitch_im_not_dead.wav | **Important** | Epidemic Sound | C05 climax; may require layering two tracks |
| Source dead_letter_arrival.wav | **Nice To Have** | Epidemic Sound | New case load tone; not yet wired |
| Source ambient_choir.mp3 | **Nice To Have** | Epidemic Sound | P07 Undercity Refuge; Ch7 only |
| Source ambient_meridian.mp3 | **Nice To Have** | Epidemic Sound | Ch5 Helix Premium aesthetic |
| Source all remaining SFX (9 items) | **Nice To Have** | Epidemic Sound | See AudioProductionPlan.md Sessions 3–5 |
| Import and wire all audio files | **Critical Path** (after sourcing) | Xcode | Drop into bundle; no code changes required for wired tracks |

---

### 1.5 UI/UX

| Task | Priority | Notes |
|---|---|---|
| **Contradiction panel visibility** | **Critical Path** | See Programming section; this IS the game's core mechanic |
| **Suspicious field marker (◆ indicator)** | **Critical Path** | See Programming |
| Document zoom / expand | **Important** | See Programming |
| Debug menu access | **Important** | See Programming |
| Chapter Select: completion checkmark + timestamp | **Nice To Have** | Visual polish; ChapterCompleteScene functional |
| Stamp icon art wired | **Nice To Have** | Buttons readable as text; icons are polish |
| Chapter splash images in ChapterSelectScene | **Nice To Have** | Text cells functional; splash art is T3 |
| Dialogue scene upper-right void | **Nice To Have** | See BibleGapAnalysis.md architectural debt |
| Numeric display on HUD bars (tap to see value) | **Nice To Have** | Accessibility improvement |

---

### 1.6 Testing

| Task | Priority | Notes |
|---|---|---|
| Playtest Ch1 with contradiction UI active | **Critical Path** | Validate the 5-minute normal player estimate holds after UI fix |
| Playtest Ch2 end-to-end (all action variants on all 3 cases) | **Critical Path** | Verify all flags set correctly; restricted sector gate; routing anomaly trigger |
| Verify Ch1 consequence flag reads in Ch3 (C09 callback) | **Important** | Test before Ch3 is shipped; flag system is the game's emotional spine |
| Verify negative complianceScore delta (C08 Illegal Forward) | **Important** | First negative delta in the game |
| Three-ending verification (full Ch1–8 playthrough × 3) | **Post-sprint** | Full game must exist before this test |
| UITest suite expansion | **Nice To Have** | Add after Ch2 stable |
| Real device testing (iOS 26 physical) | **Important** | Fullscreen fix unverified on real hardware |
| Performance: 60fps with parallax + 5 enemies | **Nice To Have** | Profile after art assets exist |

---

### 1.7 Release Preparation

| Task | Priority | Notes |
|---|---|---|
| App icon (1024×1024) | **Important** | Required; currently Xcode placeholder |
| App Store metadata (name, subtitle, description, keywords) | **Important** | Bible Section 14 has approved copy |
| Privacy policy URL | **Important** | Required even for zero-data-collection apps |
| Age rating: 12+ | **Important** | Set in App Store Connect |
| Screenshots (5, landscape 6.9") | **Important** | Requires completed Ch1 art pass |
| Real device / UIRequiresFullScreen verification | **Important** | Must confirm before submission |
| TestFlight internal build | **Important** | Before external playtest |
| AI art licence confirmation (DreamShaper XL Turbo commercial use) | **Important** | Confirm before App Store submission |
| App Store submission | **Post-sprint** | After Phase 8 testing complete |

---

## Part 2: Current Project Risks

| Risk | Severity | Probability | Impact | Mitigation |
|---|---|---|---|---|
| **R1: Core mechanic not visible to player** | Critical | Confirmed | Player cannot play the game correctly; playtesting unreliable | Fix contradiction UI before any other programming work |
| **R2: portrait_audit_voice missing** | Critical | Confirmed | All Chapter 2+ dialogue blocked; cannot test Ch2 narrative | Generate tonight via DiffusionBee |
| **R3: Writing volume for solo dev** | High | High | 19 cases × 6 docs × ~200 words = ~22,800 words of document prose | Use Claude Code for schema + ChatGPT for prose; ContentExpansionPlan designs reduce ideation time to near-zero |
| **R4: All audio missing** | High | Confirmed | Game is silent; playtesting without audio misjudges pacing and tone | Source Session 1 (4 tracks) within first 5 days; immediately transformative |
| **R5: iOS 26 real device fullscreen unverified** | High | Unknown | App Store rejection or broken fullscreen on production hardware | Test on physical device as soon as build is Ch1-stable |
| **R6: Mid-chapter dialogue interrupt not implemented** | Medium | Probable | Ch2's conditional routing anomaly trigger (n1) requires DeskScene to fire DialogueScene between cases; may need new code | Scope this before Ch2 content is wired; may only need small change |
| **R7: Content pipeline slowdown at Ch3** | Medium | High | C09's four consequence variants (reading C01 flag) is the most complex JSON in the game; first time flag-reading changes document content | Design C09 variants explicitly before writing; test flag read before Ch3 ships |
| **R8: Ladder mechanic unimplemented** | Medium | Confirmed | P04 Records Annex design requires climb; MaraPlayerNode has no climb state | Plan as Ch4 engineering task; doesn't block Ch2–3 |
| **R9: Timed door mechanic unimplemented** | Medium | Confirmed | P06 Black Mail Train design requires timed doors and drone-door synchronisation | Plan as Ch6 engineering task; doesn't block Ch2–5 |
| **R10: Content runtime gap** | Medium | Confirmed | Current projection at Ch1 density = 35 min total; target = 3 hours | Addressed by ContentExpansionPlan.md; requires discipline on document depth |
| **R11: No debug menu** | Medium | Confirmed | QA of Ch2–8 without ability to jump chapters or inspect flags will be very slow | Build debug menu before Ch3 ships |
| **R12: AI art commercial licence** | Low | Possible | DreamShaper XL Turbo commercial use terms must be confirmed before App Store | Add to pre-submission checklist; research before Phase 9 |

---

## Part 3: Effort Estimates

### Basis for estimates
- Solo developer with AI assistance (Claude Code for schema-exact JSON, ChatGPT for prose first drafts)
- ContentExpansionPlan.md and Ch2 Design Package reduce ideation time to near-zero for Ch2–3
- Later chapters (Ch4–8) require design work before writing; factor this in
- "Hours" = focused working hours, not calendar time

---

### Chapter 2 ("The Misfiled Living")

| Component | Hours | Notes |
|---|---|---|
| portrait_audit_voice (generate + post-process + import) | 1–2 | Blocking dependency; do first |
| cases_ch2.json — C06, C07, C08 | 4–6 | 18 documents; prose for each doc body; Ch2 Design Package provides exact field specs |
| intro_ch2.json — 3 nodes + system note | 1–2 | Dialogue content specified in Ch2 Design Package |
| level_ch2.json — P02 Sorting Centre | 2–3 | 12 interactables, 5 drones; full spec in Ch2 Design Package |
| Code: wire Ch2 content, verify flags, test restricted sector gate | 2–3 | No new mechanics except drone indicator (optional) |
| Code: mid-chapter dialogue interrupt (if not yet implemented) | 2–4 | Scope before starting; may be small or may require a new code path |
| Playtest Ch2 (all action variants, all 3 cases) | 2–3 | Full decision tree coverage |
| **Chapter 2 total** | **14–23 hours** | |

---

### Chapter 3 ("The Daughter Clause")

| Component | Hours | Notes |
|---|---|---|
| cases_ch3.json — C09 (4 consequence variants), C10, C11 | 7–10 | C09 is the most complex case in the game's first half; 4 variants read C01 flag; each variant changes 2–3 document fields |
| intro_ch3.json — Calyx memo pre-desk, cascade trigger, post-desk | 2–3 | Calyx memo as queue item (not a dialogue portrait scene) is a new UI pattern — scope before writing |
| level_ch3.json — P03 Lower Housing Block, terminal varies by flags | 2–3 | Terminal content reads C01+C09 flags; flag-reading already implemented |
| Code: consequence flag read validation (C09 reads C01) | 1–2 | Verify DeskScene/GameState reads prior-chapter flags correctly; test explicitly before shipping |
| Code: Calyx memo as queue item (if distinct UI handling needed) | 1–3 | If Calyx's memo is a non-stampable document type, may need small DeskScene change |
| Playtest Ch3 (all C01 × C09 combinations = 4 paths through C09) | 3–4 | Four paths need independent verification |
| **Chapter 3 total** | **16–25 hours** | |

---

### Chapter 4 ("Ghost Audit")

| Component | Hours | Notes |
|---|---|---|
| cases_ch4.json — C12, C13, C14 | 6–8 | C13 (Mara's own death notice) is the hardest case to write in the game; C14 requires Calyx memo documents |
| Code: C13 stamp-lock mechanic (buttons locked until all 6 docs opened) | 2–3 | Small DeskScene addition; first time this mechanic is used |
| Code: ladder climb mechanic in MaraPlayerNode | 4–6 | New movement state; `ladder` interactable type exists in data but mechanic is unimplemented |
| Code: Ghost Audit scanner zones in PlatformScene | 2–4 | Sweeping detection beam; "don't stand still" mechanic; new enemy logic |
| intro_ch4.json — pre-desk performance review, C13 pause trigger, Calyx visit | 2–3 | Mid-chapter trigger (after C13) is the longest dialogue pause in the game |
| level_ch4.json — P04 Records Annex with scanner zones and vent ladders | 3–4 | Requires ladder interactables and scanner zone placement |
| Playtest Ch4 | 3–4 | Ghost Audit scanner + ladder + C13 moral weight = most playtesting surface in first half |
| **Chapter 4 total** | **22–32 hours** | Highest engineering content of any chapter due to new mechanics |

---

### Chapters 5–8 (Combined Estimate)

| Chapter | Narrative + Level | Code | Testing | Total |
|---|---|---|---|---|
| Ch5 — Afterlife Premium | 10–14h | 2–3h (no new mechanics) | 2–3h | **14–20h** |
| Ch6 — Black Mail Train | 10–14h | 8–12h (timed doors + drone-door sync for P06) | 3–4h | **21–30h** |
| Ch7 — Choir Beneath | 12–16h | 2–3h (no new mechanics; P07 tone shift is art/level design) | 3–4h | **17–23h** |
| Ch8 — Dead Letter Office | 14–18h | 3–4h (three ending dialogue variants, decision terminal) | 4–5h | **21–27h** |
| **Ch5–Ch8 total** | | | | **73–100h** |

---

### Engineering-Only Backlog (not chapter-specific)

| Task | Hours |
|---|---|
| Contradiction UI implementation | 4–8 |
| Suspicious field highlighting | 2–3 |
| Document zoom / expand | 3–5 |
| Debug menu / DebugScene | 4–6 |
| EvidenceScene | 6–8 |
| Drone facing indicator | 2–3 |
| Replay mode flag | 1–2 |
| UITest suite expansion (3 tests) | 3–4 |
| **Engineering backlog total** | **25–39h** |

---

### Full Project Remaining Effort Summary

| Category | Hours |
|---|---|
| Narrative (Ch2–8 content + Ch1 enrichment) | 85–120 |
| Programming (chapter-specific + backlog) | 60–95 |
| Art (all remaining assets) | 28–44 |
| Audio (sourcing + import) | 10–15 |
| Testing (all chapters) | 25–35 |
| UI/UX (beyond programming estimates) | 5–8 |
| Release preparation | 8–14 |
| **TOTAL** | **221–331 hours** |

**At 4 focused hours per day:** 55–83 days = **2–3 months to content complete**
**Polish + testing + release:** 4–6 additional weeks
**Realistic App Store date:** **September–October 2026**

---

## Part 4: Optimal Tool Sequencing for Solo Developer

The key insight for solo development with multiple tools: different tools occupy different cognitive modes. Rotate between them to avoid fatigue and maximise throughput.

### Tool Roles

| Tool | Best Used For | Cognitive Mode |
|---|---|---|
| **Claude Code** | JSON file writing (cases, dialogues, levels) with exact schema matching; reading existing files and continuing patterns; wiring content to the engine | High focus; structured output |
| **ChatGPT** | First-draft document body text (the 200-word prose inside each case document); dialogue tone iteration; case narrative brainstorming | Creative; iterative; conversational |
| **Xcode / SpriteKit** | All code implementation; wiring JSON content; testing; performance profiling | High focus; requires build feedback loop |
| **DiffusionBee** | Character portraits; scene backgrounds; sprites; UI icons | Low active attention; run batches and review; good for parallel with other work |
| **ComfyUI** | Platform parallax layers (wider strips needing seamless tiling); more complex generation workflows | Medium attention; better than DiffusionBee for wide-format assets |
| **Epidemic Sound** | Audio sourcing; browser-based; preview tracks against the build | Light attention; good between programming sessions |

### Rotation Pattern (Optimal Daily Structure)

```
Morning session (2 hours):    Xcode — programming or wiring
Midday session (1 hour):      DiffusionBee — set generation running; review results
Afternoon session (2 hours):  Claude Code — JSON content writing
Evening (30–60 min):          ChatGPT — draft prose for next day's JSON writing
                              OR Epidemic Sound — audio sourcing
```

This rotation avoids burnout on any single tool and keeps parallel tracks progressing. The DiffusionBee midday session is passive (set prompt, watch results) — run it while eating or reviewing output from the morning session.

### Content Writing Protocol

For each case, the optimal pipeline is:
1. **ChatGPT (15–20 min):** Generate rough prose drafts for each document's body text, using the design spec as a brief. Ask for 200-word bureaucratic documents in the game's voice. Get 2–3 variants per document.
2. **Claude Code (30–45 min per case):** Open the existing cases_ch1.json, read the schema, write the new case JSON with the ChatGPT prose integrated and all field/suspicious/contradiction data from the design spec.
3. **Xcode (15 min per case):** Build and run; navigate to the case in-game; verify tabs load, suspicious fields visible, contradiction panel populates.

This pipeline produces approximately 1 complete, tested case every 90 minutes when the design spec is detailed (as Ch2's is).

---

## Part 5: Day-by-Day Sprint Recommendations

### Tonight (2026-06-02)

**Goal:** Remove the two most critical blockers.

**Session 1 — DiffusionBee (60–90 min)**
Generate `portrait_audit_voice`. This is the single most blocking dependency in the project. Every Chapter 2+ dialogue node requires it.
- Use prompt from AssetProductionPlan.md P-002
- Run 10 batches; select the cleanest geometric composition
- Post-process: posterize level 5, pure black background `#050810`, amber slit `#FFB533`
- Import to `Assets.xcassets/portrait_audit_voice.imageset/`
- Mark P-002 as Approved in AssetProductionPlan.md

**Session 2 — Xcode (90–120 min)**
Begin the contradiction UI implementation in DeskScene. This is the highest-leverage code task in the project.
- The Contradiction model exists in CaseFile
- The contradiction data is in every case JSON
- The task is rendering a panel in DeskScene when the player has viewed enough documents to see the contradiction
- This does not require new data — only new rendering code

**Tonight's output:** `portrait_audit_voice` in catalog. Contradiction UI in progress or complete.

---

### Tomorrow (2026-06-03)

**Goal:** Unlock Ch2 content pipeline.

**Morning — Xcode (2 hours)**
Complete contradiction UI if not finished tonight. Then implement suspicious field highlighting — `isSuspicious: true` fields render with a `◆` marker in amber. Both features use existing model data; both require only DeskScene/DocumentNode rendering changes.

By end of morning: the game's core mechanic is visible for the first time.

**Midday — DiffusionBee (60 min)**
While reviewing morning's code work: generate `bg_desk_office` (BG-001).
- Use prompt from AssetProductionPlan.md
- Run 6 batches; select clearest overhead desk composition
- Post-process and import

**Afternoon — Claude Code (2 hours)**
Write `Data/Cases/cases_ch2.json` — Case C06 (Garr Sen).
- Open `cases_ch1.json` to confirm schema
- Use Ch2 Design Package Rev. 2 as the complete specification; every field, every document, every contradiction is defined
- Write C06 completely including all 6 documents, all suspicious fields with suspicionNote text, all contradictions, all 3 actions with consequences and result texts
- Build and test in Xcode: navigate to C06, verify tabs, verify Flag Anomaly sets `c06_flag_anomaly_used`

**Evening — ChatGPT (45 min)**
Draft prose for C07 (Alia Brent) case documents:
- Brief ChatGPT: "Write a 200-word bureaucratic Medical Death Note in the voice of a government healthcare system that views patients as administrative events. Patient is Alia Brent. Data Fever. Lucid on 2147.03.19. Dead 2147.03.21."
- Repeat for each C07 document
- Save drafts for tomorrow's Claude Code session

**Tomorrow's output:** Contradiction UI and suspicious fields working. C06 playable. `bg_desk_office` generated. C07 prose drafted.

---

### Days 3–4 (2026-06-04–05)

**Day 3 Morning — Claude Code (2 hours)**
Write C07 (Alia Brent) and C08 (Courier 19) into cases_ch2.json.
- C07: 6 documents; primary/secondary/tertiary contradictions; 4 action variants
- C08: 6 documents including Routing Intercept Log (new in Rev. 2); waveform peak data and map coordinate data must match exactly (3.1/7.4/12.8/15.2/19.6/24.1)
- All result texts as specified in Ch2 Design Package (the censor result text for C07 is the chapter's most important prose — write it carefully)

**Day 3 Afternoon — Claude Code (2 hours)**
Write `Data/Dialogues/intro_ch2.json`.
- 3 nodes + 1 system note (n0, n1, n1b, n2)
- Dialogue lines verbatim from Ch2 Design Package
- Conditional flags specified; verify n1 requires `c06_flag_anomaly_used`
- Flag n1b as system note (minimal DialogueScene or in-desk notification — note in file which implementation path is required)

**Day 4 — Claude Code + Xcode (4 hours)**
Write `Data/Levels/level_ch2.json` — P02 Sorting Centre.
- 12 interactables as specified in Ch2 Design Package
- 5 drone patrols with speeds and patrol ranges
- Restricted sector door gated by `c08_illegal_forward_used`
- Data cartridge with the 8-name list text
- Wire in Xcode; test full Ch2 run-through from Ch1 completion
- Verify routing anomaly trigger fires when `c06_flag_anomaly_used` is set
- Verify negative complianceScore delta on C08 Illegal Forward

**Days 3–4 output:** cases_ch2.json complete. intro_ch2.json complete. level_ch2.json complete. Ch2 playable end-to-end.

---

### Days 5–6 (2026-06-06–07)

**Day 5 — Audio (3 hours) + Art (1 hour)**

**Audio Session 1 — Epidemic Sound (2 hours):**
Source the four most critical tracks:
1. `ambient_desk.mp3` — search: "dark minimal electronic loop", "tense ambient bureaucratic"; target 60–90s loop, no drums, ~65 BPM
2. `stamp.wav` — search: "rubber stamp hard impact", "document stamp thud"; target 0.4–0.6s
3. `page_turn.wav` — search: "paper flip short", "document page turn"; target 0.2–0.4s
4. `ambient_platform.mp3` — search: "industrial ambient loop", "underground electronic pulse"; target 60–90s loop

Import all four into Xcode bundle. Build and run — the game should no longer be silent.

**Audio validation in Xcode (1 hour):**
Verify AudioManager plays each track at the correct scene. Confirm no console warnings about missing files.

**DiffusionBee (concurrent with audio sourcing, passive):**
Generate `bg_main_menu` (BG-002) while reviewing Epidemic Sound tracks.

**Day 6 — Ch1 Enrichment (4 hours)**

This is the work that takes Chapter 1 from 5 minutes to 20–25 minutes. The ContentExpansionPlan.md specifies exactly what to add to each case.

**Claude Code / ChatGPT rotating pipeline:**
- Add PMCA Queue Instruction document to C01–C05 (5 new documents; ~60–120 words each)
- Add secondary contradictions to C01–C05 (requires adding new Contradiction entries and the supporting document that makes each secondary contradiction visible)
- Increase primary document body text from ~100 → ~200 words per case (ChatGPT drafts; Claude Code integrates)

Priority order for enrichment: C05 (the finale case) → C04 (Elias routing tag) → C01 (Olen Marr; sets up Ch3 Lina callback) → C02/C03

**Days 5–6 output:** Game has audio. Ch1 at ~15–20 minute target. bg_main_menu generated.

---

### Days 7–9 (2026-06-08–10)

**Day 7 — P01 Expansion + Ch1 Dialogue**

**Claude Code (2 hours):** Expand `level_ch1.json` P01 from 3,000 → 5,000 pt.
- Add locked terminal (requires C03 action flag)
- Add 4 environmental signs (world-building text from ContentExpansionPlan.md)
- Add optional dead-end room with 12-name list
- Extend patrol coverage for new section

**Claude Code (2 hours):** Write post-desk Ch1 dialogue node (Jun Vale first contact).
- Add to `intro_ch1.json` as new node gated by `ch1_chapter_complete`
- Jun Vale's contact through the dead-letter system — tone: careful, coded, not yet explanatory
- Verify portrait_audit_voice displays correctly (Audit Voice response node)

**Day 8 — Audio Session 2 + Debug Menu**

**Epidemic Sound (2 hours):**
Source Session 2 tracks:
1. `ambient_mainmenu.mp3`
2. `chapter_complete.mp3`
3. `terminal_beep.wav`
4. `drone_alert.wav`

**Xcode (2 hours):** Begin DebugScene / debug menu.
- Reset save, load case, inspect flags, jump scene, set variables
- Essential for Ch3+ QA; building it now saves hours during content testing
- This is the last piece of infrastructure needed before the content pipeline scales

**Day 9 — Platform Parallax + Ch1 Testing**

**ComfyUI / DiffusionBee (2 hours):**
Generate platform parallax layers in a single session with the same seed family:
- PL-001 `bg_city_far` — 3 colours, far silhouette
- PL-002 `bg_facility_mid` — 6 colours, industrial mid-ground
- PL-003 `bg_facility_near` — PNG with alpha, upper 50% transparent

**Xcode (2 hours):**
Playtest Ch1 fully enriched version. Target: 20–25 minutes normal player.
- Time the playthrough by segment
- Verify contradiction UI working across all 5 cases
- Verify suspicious field markers on all flagged fields
- Verify C05 glitch animation still fires correctly

**Days 7–9 output:** Ch1 at 20–25 minute target. Debug menu built. Audio Session 2 complete. Platform parallax layers generated. P01 expanded.

---

### Days 10–12 (2026-06-11–13)

**Day 10 — Ch3 Design + Writing Begins**

**ChatGPT (1 hour):**
Generate prose drafts for C09 Olen Marr Follow-up — all 4 consequence variants.
- Brief ChatGPT with the C01 decision outcomes (Approve/Censor/Reject/Illegal Forward) and what each means for Lina's situation
- Draft variant document text for each path (PMCA Queue Instruction framing varies per variant; Relocation Confirmation present/absent per variant)

**Claude Code (3 hours):**
Write `Data/Cases/cases_ch3.json` — C09.
- This is the most technically complex case in the first half: 4 document variants reading a prior chapter's flag
- Implement the consequence callback: `flagsRequired` or document variant condition based on C01 decision flag
- Verify GameState correctly stores and reads C01 action flag across chapter boundaries

**Day 11 — Ch3 Cases C10 + C11**

**Claude Code + ChatGPT (4 hours):**
Write C10 (Fara Dain) and C11 (Kell Orvin) into cases_ch3.json.
- C10: The relocation form signed 48 hours before admission; Helix occupancy forecast
- C11: Entropy score 0.23 (below live threshold — this is where the mechanic introduced in C08's 0.41 is clarified); planted confession; supervisor J. Harrel-09 in security log
- Full document specifications in ContentExpansionPlan.md

**Day 12 — Ch3 Dialogue + Level**

**Claude Code (2 hours):** Write `intro_ch3.json`.
- Pre-desk: Calyx memo in queue (note: if Calyx's memo is non-stampable, this requires a UI note in the JSON or a flag in the document type)
- Mid-chapter: One-line system note after C09 ("familial cascade — active")
- Post-desk: 847 relocation orders statistic; Mara's unanswered question

**Claude Code (2 hours):** Write `level_ch3.json` — P03 Lower Housing Block.
- Terminal content varies based on C01+C09 flags — the first time two prior-chapter flags combine
- Environmental storytelling: relocation notices, grief shrine, empty apartment
- 4 drones, 10 interactables, 5,500 pt width

**Days 10–12 output:** Ch3 cases written. Ch3 dialogue written. Ch3 level written.

---

### Days 13–14 (2026-06-14–15)

**Day 13 — Ch3 Wire and Test + Art Pass**

**Xcode (2 hours):**
Wire and test Ch3 end-to-end.
- Critical test: verify C09 reads C01 flag correctly across all 4 paths
- Verify C11 entropy note doesn't contradict C08 setup (0.23 < 0.40 threshold; different from C08's 0.41 ambiguity)
- Verify familial cascade system note fires after C09
- Verify P03 terminal reads both C01 and C09 flags

**DiffusionBee (2 hours, concurrent):**
Generate `portrait_elias_venn` (img2img from `portrait_mara` at 0.20 strength).
Generate `bg_chapter_complete`.

**Day 14 — Sprint Review + Next Sprint Planning**

**Xcode (1 hour):**
Full Ch1 → Ch2 → Ch3 playthrough, one path. Time it. Target: 65–80 minutes total.

**Claude Code (1 hour):**
Update `docs/PROJECT_STATUS_JUNE_2026.md` with sprint outcomes.

**Writing (1 hour):**
Produce the next 14-day sprint plan, scoping Ch4 engineering work (ladder mechanic, C13 stamp-lock, Ghost Audit scanner zones).

**Review (1 hour):**
Assess what slipped and why. Adjust effort estimates for Ch4 accordingly.

---

## Part 6: Sprint Target Summary

| Day Range | Focus | Output |
|---|---|---|
| Tonight | Remove critical blockers | portrait_audit_voice in catalog; contradiction UI started |
| Tomorrow | Unlock Ch2 pipeline | Contradiction UI + suspicious fields live; C06 playable; bg_desk_office generated |
| Days 3–4 | Ch2 content complete | cases_ch2.json, intro_ch2.json, level_ch2.json all written and wired; Ch2 playable end-to-end |
| Days 5–6 | Audio + Ch1 production density | Audio Session 1 imported; Ch1 at 15–20 min runtime; bg_main_menu generated |
| Days 7–9 | Ch1 locked + infrastructure | Ch1 at 20–25 min; debug menu built; P01 expanded; platform parallax generated; Audio Session 2 |
| Days 10–12 | Ch3 content complete | cases_ch3.json, intro_ch3.json, level_ch3.json written; consequence callbacks tested |
| Days 13–14 | Ch3 wired + sprint review | Ch3 playable; portrait_elias_venn generated; sprint report updated |

---

## Part 7: Production Roadmap — Fastest Route to Commercial Release

### Phase 1: Chapter 1 Lock (Sprint 1, Days 1–9)
**Definition of done:** Ch1 is a complete, shippable demo with no placeholder art on the critical path.

- Contradiction UI + suspicious field highlighting ✓
- Ch1 cases enriched to 6 documents each ✓
- Ch1 runtime: 20–25 minutes ✓
- P01 expanded to 5,000 pt ✓
- `portrait_audit_voice` in catalog ✓
- `bg_desk_office`, `bg_main_menu` in catalog ✓
- Audio Session 1 (desk, stamp, page turn, platform) imported ✓
- Post-desk Ch1 dialogue node (Jun Vale first contact) ✓
- Chapter 1 playtest with stranger: validate 20-minute target

**Calendar estimate:** 2026-06-10 (end of Day 9)

---

### Phase 2: Chapters 2–3 Complete (Sprint 1–2, Days 1–28)
**Definition of done:** Chapters 1–3 playable end-to-end; consequence callbacks tested; content pipeline validated for Chapters 4–8.

- Ch2 content complete and playable ✓ (by Day 5)
- Ch3 content complete and playable ✓ (by Day 14)
- Debug menu / DebugScene built ✓
- Audio Session 2 (mainmenu, chapter_complete, terminal beep, drone alert) ✓
- Platform parallax layers in catalog ✓
- `mara_silhouette` generated and wired
- `portrait_elias_venn` generated ✓
- `bg_chapter_complete` generated ✓
- Drone facing indicator in PlatformScene
- Document zoom / expand implemented
- iOS 26 real device test (fullscreen verification)

**Calendar estimate:** 2026-06-28 (end of two-week sprint 2)

---

### Phase 3: Chapter 4 + Mid-Game Systems (Sprint 3, ~3 weeks)
**Definition of done:** Ch4 playable; all mid-game mechanics implemented; Chapters 1–4 form a coherent arc.

Engineering:
- Ladder climb mechanic in MaraPlayerNode ✓
- Ghost Audit scanner zones in PlatformScene ✓
- C13 stamp-lock mechanic (all docs required before stamp) ✓
- EvidenceScene (needed for Ch5+ platform-to-desk evidence) ✓
- Mid-chapter dialogue interrupt (if not yet implemented)

Content:
- cases_ch4.json, intro_ch4.json, level_ch4.json ✓
- Audio Session 3 (ambient_ending, glitch_im_not_dead, dead_letter_arrival) ✓

**Calendar estimate:** 2026-07-19

---

### Phase 4: Chapters 5–6 (Sprint 4, ~4 weeks)
**Definition of done:** Elias truth track complete; Black Mail Train platform section playable; all Ch5–6 content wired.

Engineering:
- Timed door mechanic for P06 (Black Mail Train)
- Drone-door synchronisation for P06
- Helix Meridian desk audio (`ambient_meridian.mp3`)

Content:
- Ch5: cases_ch5.json, intro_ch5.json, level_ch5.json (C15 Elias archive stub; Afterlife Premium cases)
- Ch6: cases_ch6.json, intro_ch6.json, level_ch6.json (C19 Orra fragment; Black Train Manifest)
- `portrait_audit_voice` wired in all Ch2–6 dialogue (already done by this phase)

**Calendar estimate:** 2026-08-16

---

### Phase 5: Chapters 7–8 + Story Complete (Sprint 5, ~4 weeks)
**Definition of done:** Full game playable from Ch1 to all three endings; all 24 cases implemented.

Content:
- Ch7: cases_ch7.json, intro_ch7.json, level_ch7.json (Jun Vale confrontation; C23 seven-document Elias packet)
- Ch8: cases_ch8.json, intro_ch8.json, level_ch8.json (C24 Orra complete letter; three-path Central Archive)
- Three ending dialogue variants (Archive/Broadcast/Erasure)
- All consequence callback chains validated (Lina Marr: C01→C09→C12; Elias: C04→C15→C18→C23; Orra: C19→C20→C24)

Art:
- `ambient_choir.mp3` for P07
- Chapter splash screens (T3) — last art priority

**Calendar estimate:** 2026-09-13

---

### Phase 6: Art Pass (Sprint 6, ~3 weeks)
**Definition of done:** No procedural placeholder art visible in normal gameplay.

- All 6 stamp icons generated and wired ✓
- 2 UI collectible icons ✓
- Document paper texture ✓
- 3 ending backgrounds (if deferred) ✓
- `bg_boot_screen` ✓
- 8 chapter splash screens ✓
- App icon (1024×1024) ✓
- `sprite_security_drone` ✓

**Calendar estimate:** 2026-10-04

---

### Phase 7: Audio Pass (Sprint 6, concurrent with Art Pass, ~2 weeks)
**Definition of done:** All scenes have music; all documented SFX wired; no silent moments during normal gameplay.

- Audio Sessions 4–5 sourced from Epidemic Sound ✓
- All 10 priority audio files imported ✓
- All new SFX methods added to AudioManager ✓
- Stamp differentiation (approve/reject/censor as distinct sounds) wired ✓
- N-01 Audit Voice processing effect (if pursuing custom audio) ✓

**Calendar estimate:** 2026-10-04 (concurrent with Phase 6)

---

### Phase 8: Polish + Full Playthrough Testing (Sprint 7, ~3 weeks)
**Definition of done:** Three complete playthroughs verified; no crashes in 5 full runs; 60fps on physical device.

- Three-ending playthroughs: Broadcast / Control / Erasure ✓
- All consequence callbacks verified across full playthrough ✓
- UITest suite expanded (5 total tests) ✓
- Performance test: 60fps with full parallax + 5 enemies ✓
- Real device test: fullscreen on iOS 26 hardware ✓
- All architectural debt items resolved or documented as acceptable ✓
- Replay mode flag implemented ✓

**Calendar estimate:** 2026-10-25

---

### Phase 9: App Store Preparation + Submission (Sprint 8, ~2 weeks)
**Definition of done:** App submitted and approved.

- App icon in all required sizes ✓
- App Store metadata (name, subtitle, description, keywords) ✓
- Privacy policy URL live ✓
- Age rating: 12+ ✓
- 5 landscape screenshots (6.9") ✓
- TestFlight internal build ✓
- AI art commercial licence confirmed ✓
- App Store submission ✓
- App Store review: 1–7 business days (not within developer's control)

**Calendar estimate:** 2026-11-08 (submission) → 2026-11-15 (approval target)

---

### Summary Timeline

| Phase | Focus | End Date | Duration |
|---|---|---|---|
| Phase 1 | Ch1 Lock | 2026-06-10 | 9 days |
| Phase 2 | Ch2–3 Complete | 2026-06-28 | 18 days |
| Phase 3 | Ch4 + Mid-Game Systems | 2026-07-19 | 21 days |
| Phase 4 | Ch5–6 | 2026-08-16 | 28 days |
| Phase 5 | Ch7–8 + Story Complete | 2026-09-13 | 28 days |
| Phase 6 | Art Pass | 2026-10-04 | 21 days |
| Phase 7 | Audio Pass | 2026-10-04 | (concurrent with Phase 6) |
| Phase 8 | Testing + Polish | 2026-10-25 | 21 days |
| Phase 9 | Release | 2026-11-15 | 21 days |

**Target launch: November 2026**
**Confidence level: Medium-High** — timeline assumes consistent 4h/day velocity; delays in Phase 3 or 5 engineering work are the highest risk to this date.

---

## Part 8: Producer's Critical Path Statement

Three things, in order, determine whether this game ships on time:

**1. The content pipeline.** One case per 90 minutes with AI tools is achievable. The design documents (ContentExpansionPlan.md, Ch2 Design Package) have already done the design work. The writing is now an execution problem, not a creative problem. Maintain the pipeline cadence of 1–2 cases per day and the content schedule holds.

**2. The Ch4 engineering sprint.** Ladder mechanic, Ghost Audit scanner, C13 stamp-lock — Phase 3 has the highest engineering density of any phase. Underestimating this by a week pushes everything by a week. Scope these three tasks explicitly before Phase 3 begins. If the ladder mechanic takes 8 hours instead of 4, know that before the sprint starts, not after.

**3. The first full playthrough.** The game's consequence callback system (C09 reads C01, C12 reads C01+C09, Elias thread across Ch4–Ch7) is the emotional spine of the game. It has never been tested end-to-end because Chapters 2–8 don't exist yet. When Phase 5 is complete, the very first full playthrough will reveal whether the flag system holds across 8 chapters. Build in 1–2 weeks of buffer after Phase 5 for this reckoning.

Everything else — art, audio, polish — is real work but it is schedulable work. The content pipeline and the consequence system are the variables that determine when this game ships.

---

*Sprint plan produced 2026-06-02. Next review: 2026-06-16 (end of 14-day sprint). Update PROJECT_STATUS_JUNE_2026.md at sprint end.*
