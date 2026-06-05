# Dead Letter Office — Bible Gap Analysis

**Source authority:** `Dead_Letter_Office_Definitive_Project_Bible_v4_FULL.docx`  
**Cross-referenced:** `CANON.md`, `AssetProductionPlan.md`, `FullGameProductionRoadmap.md`  
**Build inspected:** 2026-06-02 (Chapter 1 vertical slice, post-fullscreen fix)  
**Purpose:** Planning and documentation only. No code changes.

---

## How to Read This Document

`✅ Done` — implemented and tested  
`⚠️ Partial` — in code but incomplete or untested  
`❌ Missing` — specified in Bible, not yet in build  
`📐 Deviation` — build differs from Bible spec in a notable way

---

## 1. Preserve Working Vertical Slice

**This section is a hard constraint on all future work.**

The following are working and must never be regressed:

| Protection | Current State | Risk if Regressed |
|---|---|---|
| **Fullscreen landscape at 956×440pt** | Working on iOS 26 simulator via AppDelegate window setup | Any change to AppDelegate, Info.plist, or UIWindowScene handling could re-introduce the compact 480×320pt window |
| **Menu navigation** | Boot → Main Menu → Chapter Select → back to Main Menu works; Begin Shift works | Changes to SceneManager, SceneType enum, or MainMenuScene touch rects could silently break navigation |
| **Portrait display** | Mara Venn and Director Calyx portraits load from Assets.car; CRTEffectNode correctly overlaid | Changes to asset catalog naming, DialogueScene layout code, or portrait dimensions could break display |
| **Chapter 1 playability** | All 5 cases playable, intro dialogue works, desk interactions responsive, platform level loads | The scene-level CGRect touch system in DeskScene is the fix — do not revert to isUserInteractionEnabled child nodes |
| **Chapter 1 content** | cases_ch1.json, intro_ch1.json, level_ch1.json are the canonical content source | Editing JSON structure rather than data will break the Codable decoders |

**Build-forward rule:** All new content (chapters 2–8) must follow the Chapter 1 template exactly — same JSON schemas, same scene classes, same asset naming convention. Do not create chapter-specific Swift code.

---

## 2. Implemented Systems

### Scenes

| Scene | Bible Spec | Status |
|---|---|---|
| BootScene | ✅ Specified | ✅ Done — typewriter animation, transitions to MainMenu |
| MainMenuScene | ✅ Specified | ✅ Done — two-column landscape layout, subtitle correct, all buttons functional |
| SettingsScene | ✅ Specified | ✅ Done — music vol, SFX vol, reduced flashing, text size, subtitles |
| ChapterSelectScene | ✅ Specified | ✅ Done — 8 chapter grid, unlock logic, back button fixed |
| DeskScene | ✅ Specified | ✅ Done — document viewer, tabs, stamps, HUD bars, pause menu |
| DialogueScene | ✅ Specified | ✅ Done — portrait frame, text box, advance logic, choices, exit button |
| PlatformScene | ✅ Specified | ✅ Done — walk, jump, crouch/hide, patrol enemies, interactables, pickups |
| ChapterCompleteScene | ✅ Specified | ✅ Done — functional, transitions correctly |
| EndingScene | ✅ Specified | ✅ Done — 3 endings wired (Broadcast/Control/Erasure) |
| CreditsScene | ✅ Specified | ✅ Done — basic credits |
| EvidenceScene | ✅ Specified | ❌ Missing — Bible specifies dedicated evidence review scene (not in build) |
| DebugScene | ✅ Specified | ❌ Missing — Bible requires debug menu: reset save, load case, inspect flags, set variables, jump scene |

### Managers and Services

| Manager | Bible Spec | Status |
|---|---|---|
| SceneManager (SceneRouter) | ✅ Specified | ✅ Done — handles all transitions, scaleMode, view injection |
| GameState (GameStateManager) | ✅ Specified | ✅ Done — 6 score variables, flags, decisions, accessibility settings |
| SaveManager | ✅ Specified | ✅ Done — Codable, UserDefaults, hasSave check |
| AudioManager | ✅ Specified | ⚠️ Partial — code complete, all audio files missing |
| ConsequenceManager | ✅ Specified | ❌ Missing — consequence application is inline in DeskScene/GameState rather than a separate manager |
| AccessibilityManager | ✅ Specified | ⚠️ Partial — accessibility settings on GameState; no separate manager class |
| InputManager | ✅ Specified | ❌ Missing — platform input embedded in PlatformScene and VirtualPadNode, not a separate manager |
| AssetRegistry | ✅ Specified | ❌ Missing — assets loaded ad hoc via UIImage(named:) |
| DebugTools | ✅ Specified | ❌ Missing — no debug overlay or menu |

### Data Models

| Model | Bible Spec | Status |
|---|---|---|
| CaseFile | ✅ Specified | ✅ Done — id, chapter, senderName, senderStatus, recipientName, messageText, documents, contradictions, availableActions, correctLegalActionID, followUpFlags, requiredFlags |
| CaseDocument (DocumentModel) | ✅ Specified | ✅ Done — id, title, type (12 enum values), issuer, issueDate, referenceNumber, fields (with isSuspicious), bodyText, stamps, classificationLevel, isTampered |
| Contradiction | ✅ Specified | ✅ Done — fieldA, fieldB, description, isCritical |
| CaseAction | ✅ Specified | ✅ Done — id, label, shortLabel, color, auditResponse, consequences (ConsequenceMap), resultText, isIllegal |
| ConsequenceMap | ✅ Specified | ✅ Done — 6 delta fields, flagsSet, flagsCleared, narrativeNote |
| DocumentField | ✅ Specified | ✅ Done — key, value, isSuspicious, suspicionNote |
| Stamp (on Document) | ✅ Specified | ✅ Done — text, color, appliedDate, appliedBy |
| DialogueNode/Line | ✅ Specified | ✅ Done — id, speaker, portraitAsset, text, voiceFilter, choices, nextID, flagsRequired, flagsSet |
| PlatformLevel (LevelData) | ✅ Specified | ✅ Done — backgroundLayers, spawnPoint, exits, interactables, patrols, pickups, environmentalTextNodes |
| Interactable | ✅ Specified | ✅ Done — id, type (terminal/door/cartridge/text_sign/ladder), requiredFlag, setsFlag, requiredCode, displayText, linkedDialogueID |
| PatrolRoute | ✅ Specified | ✅ Done — enemyType, points, speed, pauseDuration |
| ChapterDefinition (ChapterData) | ✅ Specified | ✅ Done — id, title, subtitle, splashImageName, unlockRequires |
| EndingDefinition | ✅ Specified | ⚠️ Partial — endings are logic-only in DeskScene.determineEnding(), no EndingDefinition model |
| SaveData | ✅ Specified | ✅ Done — encodes all GameState fields |

### Platform Mechanics

| Mechanic | Bible Spec | Status |
|---|---|---|
| Walk (left/right) | ✅ Specified | ✅ Done |
| Jump | ✅ Specified | ✅ Done — double jump supported |
| Crouch | ✅ Specified | ✅ Done — reduces speed, changes player height |
| Hide (crouch-as-hide) | ✅ Specified | ⚠️ Partial — crouch reduces hitbox and speed; no detection-avoidance system; drones do not check if player is crouching |
| Climb (ladders) | ✅ Specified | ❌ Missing — `ladder` interactable type exists in data model but Mara has no climb mechanic |
| Interact | ✅ Specified | ✅ Done — proximity button, flags set/read |
| Read environmental text | ✅ Specified | ✅ Done — text signs display text on interact |
| Patrol enemies (drones) | ✅ Specified | ✅ Done — patrol points, pause, basic detection |
| Drone detection | ✅ Specified | ⚠️ Partial — drones detect player proximity; no vision cone or stealth calculation |
| Optional stun pulse | ✅ Specified | ❌ Missing — no stun weapon or mechanic |
| Platform assist (skip on failure) | ✅ Specified | ❌ Missing — not implemented |
| Data cartridge pickups | ✅ Specified | ✅ Done — pickups set flags on collection |

### Core Gameplay Systems

| System | Bible Spec | Status |
|---|---|---|
| Document viewing / tabs | ✅ Specified | ✅ Done — up to 4 document tabs per case, scrollable |
| Document suspicious field highlighting | ✅ Specified | ❌ Missing — `isSuspicious` exists in DocumentField model but DeskScene/DocumentNode renders all fields identically |
| Document zoom / expand | ✅ Specified | ❌ Missing — documents are fixed size in DeskScene |
| Contradiction detection / display | ✅ Specified | ❌ Missing — Contradiction model and data exist in JSON but not shown to player in UI |
| Stamp actions | ✅ Specified | ✅ Done — approve, reject, censor, archive, flag_anomaly, illegal_forward all functional |
| Consequence tracking | ✅ Specified | ✅ Done — 6 score variables, flags, caseDecisions recorded |
| Audit response per action | ✅ Specified | ✅ Done — auditResponse text shown in DeskScene message area |
| Result text per action | ✅ Specified | ✅ Done — resultText shown after stamp |
| Flag system | ✅ Specified | ✅ Done — flagsSet/flagsCleared per action, flagsRequired gating on dialogue nodes and chapters |
| Chapter completion + unlock | ✅ Specified | ✅ Done — ch[N]_chapter_complete flag, ChapterCompleteScene, ChapterSelect unlock logic |
| Three endings | ✅ Specified | ✅ Done — Broadcast/Control/Erasure determined by score comparison |
| Save/load | ✅ Specified | ✅ Done |
| Subtitles always-on default | ✅ Specified | ✅ Done |
| Reduced flashing option | ✅ Specified | ✅ Done — CRTEffectNode checks flag |
| Text size multiplier | ✅ Specified | ✅ Done |
| Music + SFX volume controls | ✅ Specified | ✅ Done |

---

## 3. Missing Systems

| System | Bible Source | Priority | Notes |
|---|---|---|---|
| EvidenceScene | Section 11 Scene List | Medium | Dedicated scene for reviewing evidence found during platform levels. May be needed for Ch5+ when physical evidence changes desk decisions. |
| DebugScene / debug menu | Section 11, Prompt 5 | High | Bible specifies: reset save, load each case, inspect flags, set hidden variables, jump scene. Currently missing. Critical for QA during Ch2–8 development. |
| Document suspicious field highlighting | Bible design pillar: "every case completable without guessing; clue must exist in documents" | High | isSuspicious flag is in model and data, but the UI does not reveal it. Player currently cannot identify contradictions without reading every field. |
| Document zoom/expand | Section 13 (Accessibility) | High | "Documents must be zoomable or expandable for readability." Currently fixed-size panels. |
| Contradiction display | Section 12 (CaseDocument model), Section 13 | High | The Contradiction model and data exist but are never shown to the player. The game's core design pillar is "compare contradictions" — this is not yet exposed. |
| Climb mechanic | Section 8 (all platform levels: "climb") | Medium | Ladder interactable type exists; MaraPlayerNode has no climb state. Required for P02+ level designs. |
| True stealth / detection system | Section 8 (all platform levels: "hide, patrol avoidance") | Medium | Currently drones only detect proximity. No vision cone, no crouch-to-hide evasion. Platform levels become harder to design without this. |
| Stun pulse | Section 8 (all platform levels: "optional stun pulse") | Low | Optional mechanic. Can be deferred until platform levels are built. |
| Platform assist (skip on failure) | Section 13 | Low | Accessibility feature. Deferred until platform levels are complete. |
| EndingDefinition model | Section 12 | Low | Endings are currently hardcoded logic. Could be JSON-driven in future. |
| ConsequenceManager (separate class) | Section 11 Manager List | Low | Currently inline in DeskScene/GameState. Functional but couples consequence logic to scene code. Refactor when Ch2+ adds new consequence types. |

---

## 4. Implemented Story Beats

| Beat | Chapter | Status |
|---|---|---|
| Opening shift: Audit Voice greeting | Ch1 | ✅ Done — intro_ch1.json, n0 |
| Director Calyx: orientation speech | Ch1 | ✅ Done — intro_ch1.json, n2 |
| Mara questions the system | Ch1 | ✅ Done — intro_ch1.json, n1 |
| Routine grief case (Olen Marr / Lina Marr) | Ch1/C01 | ✅ Done — timestamp contradiction in documents |
| Corporate suppression case (Tovin Kade) | Ch1/C03 | ✅ Done — forged Helix seal |
| Personal metadata hook (Nella Voss → Elias reference) | Ch1/C04 | ✅ Done — routing metadata with Elias prefix |
| Impossible Dead Letter: "I AM NOT DEAD" | Ch1/C05 | ✅ Done — blank death cert, corrupted transcript, glitch animation |
| Archive Walk / platform level | Ch1/P01 | ✅ Done — basic level loads, patrols functional |
| Chapter 1 completion → ChapterCompleteScene | Ch1 | ✅ Done |
| Three endings wired and reachable | Ch8 (logic) | ✅ Done — Broadcast/Control/Erasure based on accumulated scores |

---

## 5. Missing Story Beats

### Chapter 2: The Misfiled Living
- ❌ `cases_ch2.json` — C06 Garr Sen (voiceprint continues 18 min post-death), C07 Alia Brent (banned phrase misidentified), C08 Courier 19 (encoded coordinates)
- ❌ `intro_ch2.json` — false timestamp revelation, first illegal forward, first field retrieval
- ❌ `level_ch2.json` — P02 Sorting Centre (first drone sweep, data cartridge retrieval)
- ❌ Jun Vale first contact — no dialogue placing Jun in the story

### Chapter 3: The Daughter Clause
- ❌ `cases_ch3.json` — C09 Olen Marr follow-up (Lina outcome callback), C10 Fara Dain (relocation form predates diagnosis), C11 Kell Orvin (planted confession)
- ❌ `intro_ch3.json` — Lina Marr follow-up, family registry mismatch
- ❌ `level_ch3.json` — P03 Lower Housing Block (patrol light avoidance, apartment terminal)
- ❌ Lina Marr consequence callback — C09 depends on C01 decision (no followUpCases linking implemented)

### Chapter 4: Ghost Audit
- ❌ `cases_ch4.json` — C12 Lina Marr (living sender reaches Mara through Dead Letter), C13 Mara Venn (player receives their own scheduled death), C14 Director Calyx memo (Calyx describes Mara's anomalies before they occur)
- ❌ `intro_ch4.json` — risk memo, Mara's death record, Calyx meeting
- ❌ `level_ch4.json` — P04 Records Annex (access code from desk, Ghost Audit scanner)
- ❌ Mara's scheduled death as playable case — `isMaraScheduledForDeath` flag exists in GameState but no case triggers it

### Chapter 5: Afterlife Premium
- ❌ `cases_ch5.json` — C15 Elias Venn Archive Stub (closure without any closure element), C16 Sera Quill (paid legacy edit), C17 Executive Pell (three valid final messages)
- ❌ `intro_ch5.json` — executive case, Elias as technician/whistleblower/test subject
- ❌ `level_ch5.json` — P05 Meridian Service Corridor (contrast luxury with deletion machinery)
- ❌ Elias Venn truth track — no direct story path to understanding Elias's fate

### Chapter 6: The Black Mail Train
- ❌ `cases_ch6.json` — C18 Lena Harrow (Elias in trial data post-death), C19 Saint Orra Fragment (deletion count still increasing), C20 Black Train Manifest (route under sealed district)
- ❌ `intro_ch6.json` — manifest case, Saint Orra fragment
- ❌ `level_ch6.json` — P06 Black Mail Train (timed doors, drone cones, carriage transitions, Orra fragment retrieval) — **most cinematic platform level**
- ❌ Saint Orra broadcast method revealed

### Chapter 7: The Choir Beneath
- ❌ `cases_ch7.json` — C21 Jun Vale (officially dead, active in systems), C22 Quiet Choir Petition (forged signatures), C23 Elias Venn Final Packet (fragments across three systems)
- ❌ `intro_ch7.json` — Jun confrontation, Quiet Choir moral complication
- ❌ `level_ch7.json` — P07 Undercity Refuge (exploration and dialogue, environmental storytelling)
- ❌ Jun Vale confrontation — imperfect resistance vs. orderly oppression choice
- ❌ Elias Venn full reveal

### Chapter 8: Dead Letter Office (Final)
- ❌ `cases_ch8.json` — C24 Saint Orra Complete Letter (final choice: Broadcast, Control, Erasure)
- ❌ `intro_ch8.json` — Elias final packet, Orra complete letter, Calyx confrontation
- ❌ `level_ch8.json` — P08 Central Archive (final infiltration, decision terminal)
- ❌ Calyx confrontation scene
- ❌ Ending cinematics / dialogue during EndingScene (currently minimal)

---

## 6. Implemented Characters

| Character | Story Presence | Portrait | Status |
|---|---|---|---|
| Mara Venn | Protagonist, dialogue speaker, case subject (C13) | ✅ Approved | ✅ In dialog as speaker; not yet as case C13 subject |
| Director Calyx | Dialogue speaker (intro_ch1 n2) | ✅ Approved | ✅ Active in Ch1 dialogue |
| The Audit Voice | Dialogue speaker (intro_ch1 n0/n1) | ❌ Not generated | ✅ Active as speaker; placeholder portrait (correct fallback) |
| Olen Marr | Case C01 sender | None (case text) | ✅ In case data |
| Mira Sol | Case C02 sender | None (case text) | ✅ In case data |
| Tovin Kade | Case C03 sender | None (case text) | ✅ In case data |
| Nella Voss | Case C04 sender | None (case text) | ✅ In case data; references Elias |
| Unknown Sender | Case C05 ("I AM NOT DEAD") | None | ✅ In case data |

---

## 7. Missing Characters (No Story Presence Yet)

| Character | Role | Portrait | Story Gap |
|---|---|---|---|
| Jun Vale | Key resistance contact, C21 sender | ✅ Approved | Zero story presence; must appear in Ch2 dialogue and Ch7 cases |
| Saint Orra | Historical martyr, C19/C24 sender | ✅ Approved | Zero story presence; must appear in Ch6 as recurring broadcast phenomenon |
| Elias Venn | Mara's brother, C15/C23 subject | ❌ Not generated | Referenced only in C04 routing metadata; full reveal requires C15, C23, Ch8 |
| PMCA Director | Senior authority | ✅ Approved | Zero story presence; may appear in Ch4–6 as secondary antagonist |
| Lina Marr | C01 recipient, C09/C12 sender | None | Zero story presence; C09 follow-up is her callback |
| Garr Sen | C06 sender (misfiled living) | None | Entire Ch2+ cast — none yet exist in any data file |
| Alia Brent, Courier 19, Fara Dain, Kell Orvin, Lena Harrow, Sera Quill, Executive Pell | Ch2–6 senders | None | None yet exist |

---

## 8. Implemented Locations

| Location | Context | Status |
|---|---|---|
| PMCA clerk desk | DeskScene background | ⚠️ Partial — procedural dark background; `bg_desk_office` art not yet present |
| Stylised dialogue space | DialogueScene background | ⚠️ Partial — dark background only |
| Industrial corridors / archive (P01) | PlatformScene Ch1 | ⚠️ Partial — procedural colour blocks; no background art; 3 patrols, 6 interactables functional |

---

## 9. Missing Locations (No Implementation)

All the following locations have zero visual implementation (no background art, no level data):

| Location | Bible District | Platform Level | Notes |
|---|---|---|---|
| Abandoned Sorting Centre | East Transit | P02 | First major platform level after P01 |
| Lower Veyr Housing Block | Lower Veyr | P03 | Civilian atmosphere; patrol light evasion |
| PMCA Records Annex | Administrative Core | P04 | Restricted zone; Ghost Audit scanner |
| Meridian Service Corridor | Meridian Heights | P05 | Luxury vs deletion contrast |
| Black Mail Train (interior) | East Transit / sealed district | P06 | Most cinematic level; timed mechanics |
| Undercity Refuge | The Undercity | P07 | Quiet Choir home base; exploration focus |
| Central Archive (beneath PMCA) | Administrative Core | P08 | Final level; decision terminal |
| Veyr city exterior | All | Menu/transitions | `bg_main_menu` (PMCA archive interior) and `bg_chapter_complete` not yet generated |

---

## 10. Implemented Assets

| Asset | Type | Status |
|---|---|---|
| portrait_mara | Character portrait | ✅ 512×512, in Assets.car |
| portrait_calyx | Character portrait | ✅ 512×512, in Assets.car |
| portrait_saint_orra | Character portrait | ✅ 512×512, in Assets.car |
| portrait_pmca_director | Character portrait | ✅ 512×512, in Assets.car |
| portrait_jun_vale | Character portrait | ✅ 512×512, in Assets.car — not yet referenced in any dialogue |
| App icon | App Store icon | ❌ Xcode placeholder only |

---

## 11. Missing Assets

### Character Portraits

| Asset | Required For | Status |
|---|---|---|
| portrait_audit_voice | All Audit Voice dialogue lines | ❌ Not generated — geometric mask, no face |
| portrait_elias_venn | Ch6–8 Elias appearances | ❌ Not generated — img2img from portrait_mara |

### Scene Backgrounds

| Asset | Scene | Priority |
|---|---|---|
| bg_desk_office | DeskScene backdrop | T1 — visible throughout entire game |
| bg_main_menu | MainMenuScene | T1 — first impression |
| bg_chapter_complete | ChapterCompleteScene | T2 |
| bg_ending_broadcast | EndingScene (Ending A) | T3 |
| bg_ending_control | EndingScene (Ending B) | T3 |
| bg_ending_erasure | EndingScene (Ending C) | T3 |
| bg_boot_screen | BootScene texture | T3 |

### Platform Parallax Layers

Three layers per level. They are reusable across multiple levels with variant colouring. Total minimum set: 3 strips (each 6144px wide), shared across P01–P08.

| Asset | Layer | Scroll Factor |
|---|---|---|
| bg_city_far | Far | 0.1 |
| bg_facility_mid | Mid | 0.4 |
| bg_facility_near | Near (with alpha) | 0.7 |

### Player and Enemy Sprites

| Asset | Node | Current State |
|---|---|---|
| mara_silhouette | MaraPlayerNode | Procedural coloured rectangle |
| sprite_security_drone | DroneEnemyNode | Procedural text label + shape |

### Chapter Splash Screens

splash_ch1 through splash_ch8 (512×256 each). All missing. Used in ChapterSelectScene cell thumbnails.

### UI Icons and Stamps

| Asset | Use | Status |
|---|---|---|
| icon_stamp_approved | StampButtonNode — APPROVED action | ❌ Missing |
| icon_stamp_rejected | StampButtonNode — REJECTED action | ❌ Missing |
| icon_stamp_censored | StampButtonNode — CENSORED action | ❌ Missing |
| icon_stamp_forward | StampButtonNode — ILLEGAL FORWARD action | ❌ Missing |
| icon_stamp_archive | StampButtonNode — ARCHIVE action | ❌ Missing |
| icon_stamp_flag | StampButtonNode — FLAG ANOMALY action | ❌ Missing |
| icon_pickup_data | Platform data orb collectible | ❌ Missing |
| icon_cartridge | Data cartridge key item | ❌ Missing |

### Document Textures

Bible section 9 specifies 40 document texture files (document_texture_01 to 40). AssetProductionPlan v4.0 consolidates to one texture (TX-001). Both are missing.

### Props

Bible section 9 specifies 30 isolated prop images (prop_01 to 30). Not enumerated in AssetPlan v4.0. All missing.

---

## 12. Audio Requirements

AudioManager is implemented and ready. AudioManager.playMusic() and sfxAction() calls are already in every scene. All audio files are missing from the bundle.

### Music Loops (6 required per AssetPlan v4.0, 14 named in Bible section 10)

| Filename (AssetPlan v4) | Bible equivalent | Scene |
|---|---|---|
| ambient_boot.mp3 | *(not named explicitly)* | BootScene |
| ambient_mainmenu.mp3 | fluorescent_hum_loop.wav, rain_window_loop.wav | MainMenuScene |
| ambient_desk.mp3 | fluorescent_hum_loop.wav, terminal_idle_loop.wav | DeskScene |
| ambient_platform.mp3 | distant_train_loop.wav | PlatformScene |
| chapter_complete.mp3 | chapter_complete.wav | ChapterCompleteScene |
| ambient_ending.mp3 | ending_broadcast.wav | EndingScene |

### Sound Effects (4 required per AssetPlan v4, 10 named in Bible)

| Filename (code call) | Bible filename | Trigger |
|---|---|---|
| stamp.wav / stamp_approve.wav | stamp_approve.wav, stamp_reject.wav | Stamp action in DeskScene |
| page_turn.wav | *(not named)* | Document tab switch |
| terminal_beep.wav | dead_letter_arrival.wav | Terminal interactions |
| drone_alert.wav | drone_scan.wav | Drone detection in PlatformScene |

**Notable gap:** `glitch_im_not_dead.wav` — the Bible specifically names this for the C05 final case glitch animation. The glitch animation plays visually but has no accompanying audio.

---

## 13. UI Polish Requirements

| Item | Status | Notes |
|---|---|---|
| Suspicious field highlighting | ❌ Missing | isSuspicious in DocumentField model, not shown in DeskScene |
| Document zoom / expand | ❌ Missing | Fixed-size documents; hard to read on some phones |
| Contradiction indicator | ❌ Missing | Contradictions are in case JSON but not shown to player |
| Stamp icon art | ❌ Missing | Buttons show text labels only |
| Chapter splash images | ❌ Missing | ChapterSelectScene cells show text only |
| Platform level background art | ❌ Missing | Procedural colour blocks |
| App icon | ❌ Missing | Xcode placeholder |
| Debug menu | ❌ Missing | Essential for Ch2–8 QA |
| Evidence board / EvidenceScene | ❌ Missing | Needed for platform-to-desk evidence carrying in Ch4+ |
| Ending scene cinematics | ⚠️ Partial | EndingScene exists but shows text + dark background |
| Post-Chapter-1 dialogue polish | ❌ Missing | Ch2–8 dialogue not written |

---

## 14. Platform / Interlude Requirements

### Eight platform levels total — only P01 implemented

| Level | Chapter | Location | Unique Mechanic | Status |
|---|---|---|---|---|
| P01 Archive Walk | Ch1 | PMCA corridors | Tutorial; no enemies; one locked cabinet | ✅ Done (basic) |
| P02 Sorting Centre | Ch2 | East Transit | First drone sweep; data cartridge retrieval | ❌ Missing |
| P03 Lower Housing | Ch3 | Lower Veyr | Patrol light avoidance; apartment terminal | ❌ Missing |
| P04 Records Annex | Ch4 | Admin Core | Access code from desk case; Ghost Audit scanner | ❌ Missing |
| P05 Meridian Corridor | Ch5 | Meridian Heights | Contrast luxury facade vs. deletion machinery | ❌ Missing |
| P06 Black Mail Train | Ch6 | East Transit | Timed doors; carriage transitions; Orra fragment | ❌ Missing |
| P07 Undercity Refuge | Ch7 | The Undercity | Exploration + dialogue focus; no stealth required | ❌ Missing |
| P08 Central Archive | Ch8 | Admin Core | Final infiltration; decision terminal; audit lockout | ❌ Missing |

### Platform mechanics gap table

| Mechanic | P01 | P02–P08 | Status |
|---|---|---|---|
| Walk / run | ✅ | Required | ✅ Done |
| Jump (double) | ✅ | Required | ✅ Done |
| Crouch | ✅ | Required | ✅ Done |
| Climb (ladders) | ❌ | Required from P02 | ❌ Not implemented |
| Hide (true stealth) | ❌ | Required from P02 | ❌ Not implemented |
| Interact (terminals) | ✅ | Required | ✅ Done |
| Stun pulse | ❌ | Optional from P02 | ❌ Not implemented |
| Timed doors | ❌ | Required P06 | ❌ Not implemented |
| Carriage transitions | ❌ | Required P06 | ❌ Not implemented |
| Environmental text | ✅ | Required | ✅ Done |
| Platform assist (skip) | ❌ | Required | ❌ Not implemented |

---

## 15. App Store Readiness Requirements

| Requirement | Status | Notes |
|---|---|---|
| App icon (1024×1024) | ❌ Missing | Xcode default placeholder |
| App name: "Dead Letter Office" | ✅ Set in project | |
| App subtitle: "A cyberpunk thriller about the final messages of the dead." | ❌ Not set | Bible section 14 specifies exact subtitle |
| Short description | ❌ Not set | Bible section 14 has approved copy |
| Long description (170 words) | ❌ Not set | Bible section 14 has approved copy |
| Screenshot captions (5 approved) | ❌ Not set | Bible section 14 specifies all 5 |
| Screenshots (landscape, 6.9") | ❌ Missing | Requires completed Ch1 art pass |
| Privacy policy URL | ❌ Missing | Required even for zero-collection apps |
| Age rating: 12+ | ❌ Not set | Mild narrative violence |
| Target price: £2.99 / sale £1.99 | ❌ Not set | Bible section 1 specifies |
| Premium / no IAP / no ads | ✅ Correct in code | No network code, no IAP framework |
| Offline only | ✅ Correct | |
| Real device verification (iOS 26 fullscreen) | ❌ Not done | UIRequiresFullScreen on real device vs. AppDelegate fix |
| TestFlight build | ❌ Not done | |

---

## 16. Bible-to-Build Fidelity Notes

These are cases where the build deviates from the Bible in ways worth noting for future work.

| Item | Bible Specification | Build Reality | Impact |
|---|---|---|---|
| Chapter 1 case count | 5 cases (C01–C05) | 5 cases ✓ | None |
| C01 document list | Death cert, transit report, relocation notice, restricted phrase memo | DEATH CERTIFICATE, TRANSIT INCIDENT REPORT, RECIPIENT RELOCATION NOTICE, RESTRICTED PHRASE LIST — CLASS D ✓ | None — matches |
| Action verb: "Illegal Forward" | Bible canon verb | `illegal_forward` id in JSON ✓ | None |
| Action verb: "Archive" | Bible canon verb | `archive` id in JSON ✓ | None |
| Action verb: "Flag Anomaly" | Bible canon verb | `flag_anomaly` id in JSON ✓ | None |
| Asset naming | Bible section 9: `mara_portrait_neutral.png` | AssetPlan v4.0 / code: `portrait_mara` | **Deviation** — Bible section 9 uses an older naming system; AssetPlan v4.0 naming is correct and in use |
| Fullscreen mechanism | UIRequiresFullScreen in Info.plist | AppDelegate window creation (UIApplicationSceneManifest removed) | **Deviation** — plist approach doesn't work in simulator; verify on real iOS 26 device before App Store submission |
| Scene list (Bible section 11) | 12 scenes including EvidenceScene + DebugScene | 10 scenes, missing EvidenceScene and DebugScene | **Gap** — two scenes not yet built |
| Cases per chapter | Bible distributes 24 cases across 8 chapters (3 per chapter mathematically, but Ch1 has 5) | Ch1: 5 cases; Ch2–8: 0 cases | Ch1 has 2 "extra" cases vs. the 24/8=3 average. Bible itself specifies 5 for Ch1 so this is correct. |
| Contradictions visible to player | Core design pillar | Model exists, data exists, UI does not expose it | **Major gap** — the Contradiction model is populated in case JSON but DocumentNode/DeskScene never surfaces it to the player. This undermines a core pillar. |

---

## Summary: Completion State

| Category | Total Specified | Implemented | Percentage |
|---|---|---|---|
| Scenes | 12 | 10 | 83% |
| Managers | 10 | 4 complete, 2 partial | 50% |
| Data models | 12 | 11 complete, 1 partial | 92% |
| Cases (C01–C24) | 24 | 5 (Ch1 only) | 21% |
| Chapters with dialogue | 8 | 1 | 12% |
| Platform levels | 8 | 1 | 12% |
| Characters (story presence) | 7 named + 17 senders | 3 named + 5 Ch1 senders | ~35% |
| Portrait assets | 7 | 5 in catalog, 2 missing | 71% |
| Background art | 9 scenes | 0 | 0% |
| Platform parallax layers | 3 (shared) | 0 | 0% |
| Platform mechanics | 10 | 7 | 70% |
| Audio files | 10+ | 0 | 0% |
| App Store readiness | 14 items | 2 | 14% |

**Overall game completion estimate: approximately 15–20% of final product.**  
Chapter 1 vertical slice (the current milestone) is approximately 80% complete — the primary remaining gap is the art and audio pass, plus contradiction UI exposure.

---

*Analysis produced 2026-06-02. Source: Project Bible v4.0, build inspection. Read-only — no code was modified.*
