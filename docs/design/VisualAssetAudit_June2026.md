# Dead Letter Office — Visual Asset Audit
**Date:** 2026-06-02
**Role:** Art Director / Production Manager
**Sources:** Project Bible v4.0, AssetProductionPlan.md, BibleGapAnalysis.md, PROJECT_STATUS_JUNE_2026.md, asset catalog inspection, codebase scan
**Method:** Asset catalog file scan + dialogue JSON portrait reference scan + level JSON background reference scan + code review

---

## Audit Findings Summary

| Category | Required | In Catalog (with PNG) | Missing |
|---|---|---|---|
| Portraits | 7 | 5 | 2 |
| Scene Backgrounds | 7 | 0 | 7 |
| Platform Backgrounds (parallax) | 3 | 0 | 3 |
| Character / Platform Sprites | 2 | 0 | 2 |
| Stamp / Action Icons | 6 | 0 | 6 |
| Collectible Icons | 2 | 0 | 2 |
| Document Texture | 1 | 0 | 1 |
| Chapter Splash Screens | 8 | 0 | 8 |
| App Icon | 1 | 0 (imageset exists, 0 slots filled) | 1 |
| App Store Screenshots | 5 minimum | 0 | 5 |
| **TOTAL** | **42** | **5** | **37** |

**Overall visual asset completion: 5/42 (12%)**

---

## 1. Portraits

Portrait visual standard: DreamShaper XL Turbo, 392×392 px @2x, flat shading, teal upper-left / amber upper-right lighting, Menlo-adjacent bureaucratic aesthetic. All new portraits must match `portrait_mara` as the reference. Authority: `docs/Art/PortraitStyleReference.md`.

| Asset Name | Character | Narrative Role | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|---|
| `portrait_mara` | Mara Venn | Protagonist — speaker in every dialogue scene | Ch1–Ch8 | **Critical** | **Yes** — approved, PNG in catalog | No | Locked canon. Do not regenerate. |
| `portrait_calyx` | Director Calyx | Antagonist — Ch1 orientation, Ch3 pre-desk memo, Ch4 post-desk visit, Ch7 final warning, Ch8 confrontation | Ch1, Ch3–Ch4, Ch7–Ch8 | **Critical** | **Yes** — approved, PNG in catalog | No | Locked canon. Distinct from PMCA Director — younger, darker suit, near-frontal. |
| `portrait_audit_voice` | The Audit Voice | Automated overseer — speaker in EVERY chapter intro dialogue, every system notification | Ch1–Ch8 | **Critical — MISSING** | **No** — imageset does not exist in catalog | N/A | Geometric amber-slit mask. No face. Black background `#050810`. Single amber horizontal slit `#FFB533`. No body. This portrait blocks dialogue testing in Ch2 (placeholder colour shown; no crash). **Generate first.** |
| `portrait_jun_vale` | Jun Vale | Resistance contact — first named portrait appearance Ch7; Ch8 | Ch7–Ch8 | **Important** | **Yes** — PNG in catalog | Pending confirmation | File present but no formal v1 approval in AssetProductionPlan.md. Must confirm against PortraitStyleReference before wiring to any dialogue JSON. |
| `portrait_saint_orra` | Saint Orra | Historical martyr — cases C19 (Ch6), C24 (Ch8); dialogue if Ch6 requires her voice | Ch6, Ch8 | **Important** | **Yes** — approved, PNG in catalog | No | Locked canon. |
| `portrait_pmca_director` | PMCA Director | Senior authority — secondary antagonist Ch4–Ch6 | Ch4–Ch6 | **Important** | **Yes** — approved, PNG in catalog | No | Locked canon. Older man, grey hair, moustache — distinct from Calyx. |
| `portrait_elias_venn` | Elias Venn | Mara's brother — first appearance Ch5 (archive stub reveal); major presence Ch6–Ch7; referenced Ch8 | Ch5–Ch8 | **Important** | **No** — imageset does not exist in catalog | N/A | Must be generated via img2img from `portrait_mara` at 0.20 strength for sibling resemblance. Ghostly quality: reduce figure opacity to ~85% in post. See AssetProductionPlan.md P-006. |

**Portrait completion: 5/7 (71% — but the 2 missing are among the most-used in the game)**

---

## 2. Backgrounds

All scene backgrounds are currently **absent from the asset catalog**. Every scene uses a procedural dark background as a fallback. This is stable and does not crash, but means the game shows no art in any scene background.

Background visual standard: DreamShaper XL Turbo, 2668×1500 px @2x, posterize level 8, palette-corrected to game colours. Authority: `AssetProductionPlan.md`.

### 2A. Scene Backgrounds

| Asset Name | Scene | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|
| `bg_desk_office` | DeskScene | **Ch1–Ch8** (all desk sessions — majority of total game runtime) | **Critical** | **No** | N/A | The single most-played screen in the game. Overhead desk view, dark wood, CRT terminal, amber lamp. Currently procedural black. T1 priority in AssetProductionPlan.md. |
| `bg_main_menu` | MainMenuScene | App launch, all sessions | **Critical** | **No** | N/A | First impression. PMCA archive interior at night. Required for App Store screenshots. T1. |
| `bg_chapter_complete` | ChapterCompleteScene | After every chapter (Ch1–Ch8) | **Important** | **No** | N/A | Appears 8 times per playthrough. Rain-soaked city view through institutional window. T2. |
| `bg_ending_broadcast` | EndingScene (Broadcast / Ending A) | Post-Ch8 | **Important** | **No** | N/A | Underground broadcast station. T3 — deferred until story complete. |
| `bg_ending_control` | EndingScene (Control / Ending B) | Post-Ch8 | **Important** | **No** | N/A | Government surveillance command room. T3. |
| `bg_ending_erasure` | EndingScene (Erasure / Ending C) | Post-Ch8 | **Important** | **No** | N/A | Empty archive — stripped shelves, papers on floor. T3. |
| `bg_boot_screen` | BootScene | App launch (5 seconds) | **Optional** | **No** | N/A | Abstract near-black circuit texture. Very brief screen; lowest background priority. T3. |

### 2B. Platform Parallax Layers

Three layers shared across all 8 platform levels (P01–P08). Must be generated in a single session with the same seed family for visual coherence. Each strip is 6144 px wide.

| Asset Name | Layer | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|
| `bg_city_far` | Far (scroll factor 0.1) | **Ch1–Ch8** (all platform levels) | **Critical** | **No** | N/A | 3-colour max. Far city silhouette. 6144×800 px. Produces all 8 platform level backgrounds. |
| `bg_facility_mid` | Mid (scroll factor 0.4) | **Ch1–Ch8** | **Critical** | **No** | N/A | Industrial mid-ground. 6144×800 px. Same session as far layer. |
| `bg_facility_near` | Near (scroll factor 0.7) | **Ch1–Ch8** | **Critical** | **No** | N/A | Foreground pipes with alpha. Upper 50% must be transparent. PNG with alpha channel. |

**Background completion: 0/10 (0%)**

---

## 3. UI Elements

### 3A. Character / Platform Sprites

| Asset Name | Type | Scene | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|---|
| `mara_silhouette` | Player sprite | PlatformScene | **Ch1–Ch8** | **Important** | **No** | N/A | 128×192 px. Side view. Near-black teal silhouette with amber rim. Nearest-neighbour scaling only — no Lanczos. Currently a coloured rectangle in code. |
| `sprite_security_drone` | Enemy sprite | PlatformScene | **Ch1–Ch8** | **Important** | **No** | N/A | 128×96 px. Dark ovoid body, amber sensor eye. Currently a text label `▣` in code. |

### 3B. Stamp / Action Icons

All six stamp icons are needed for the DeskScene StampButtonNode. Currently, buttons show text labels only (fully readable and functional — icons are a visual polish upgrade). Stamp icons should be generated as a batch in one session.

| Asset Name | Action | Scene | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|---|
| `icon_stamp_approved` | APPROVE DELIVERY | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Oval border, dark green ink, distressed. 128×128 px. |
| `icon_stamp_rejected` | REJECT DELIVERY | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Heavy rectangle, crimson `#6B1A0A`. |
| `icon_stamp_censored` | CENSOR MESSAGE | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Filled bar / redaction shape, near-black `#0D0D0D`. |
| `icon_stamp_forward` | ILLEGAL FORWARD | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Oval with arrow, dark amber `#6B4A00`. |
| `icon_stamp_archive` | ARCHIVE | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Rectangle with filing box silhouette, dark teal `#00404A`. |
| `icon_stamp_flag` | FLAG ANOMALY | DeskScene | Ch1–Ch8 | **Important** | **No** | N/A | Diamond / triangle frame, amber-rust `#6B3A00`. |

### 3C. Collectible / Pickup Icons

| Asset Name | Type | Scene | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|---|
| `icon_pickup_data` | Data orb collectible | PlatformScene | Ch1–Ch8 | **Optional** | **No** | N/A | 64×64 px. Amber hexagonal diamond. Currently a green `◆` label in code. |
| `icon_cartridge` | Data cartridge key item | PlatformScene | Ch1–Ch8 | **Optional** | **No** | N/A | 64×64 px. Dark metal cartridge, amber indicator. Currently a `◈` label in code. |

### 3D. Document Texture

| Asset Name | Type | Scene | Chapter Used | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|---|---|
| `texture_document_paper` | Document overlay | DeskScene (DocumentNode) | Ch1–Ch8 | **Optional** | **No** | N/A | 512×768 px. Aged cream paper grain. Applied at ~35% opacity over document background. Requires a small DocumentNode code change to activate. |

**UI completion: 0/11 (0%)**

---

## 4. Chapter Transition Art

Chapter splash screens appear in ChapterSelectScene cells. Currently all cells show text titles only — fully functional but no visual thumbnails.

| Asset Name | Chapter | Priority | Exists? | Needs Revision? | Notes |
|---|---|---|---|---|---|
| `splash_ch1` | I. Orientation | **Optional** | **No** | N/A | 512×256 px. Desk / PMCA archive motif. |
| `splash_ch2` | II. The Misfiled Living | **Optional** | **No** | N/A | 512×256 px. Transit sorting facility. |
| `splash_ch3` | III. The Daughter Clause | **Optional** | **No** | N/A | 512×256 px. Housing block / relocation. |
| `splash_ch4` | IV. Ghost Audit | **Optional** | **No** | N/A | 512×256 px. Records annex / scanner beam. |
| `splash_ch5` | V. Afterlife Premium | **Optional** | **No** | N/A | 512×256 px. Corporate corridor / glass. |
| `splash_ch6` | VI. The Black Mail Train | **Optional** | **No** | N/A | 512×256 px. Moving train interior. |
| `splash_ch7` | VII. The Choir Beneath | **Optional** | **No** | N/A | 512×256 px. Undercity warmth / amber. |
| `splash_ch8` | VIII. Dead Letter Office | **Optional** | **No** | N/A | 512×256 px. Central archive / final terminal. |

**Chapter transition art completion: 0/8 (0%)**

---

## 5. Case Illustrations

**None required.** The Project Bible specifies no in-case illustrations. Document presentation is entirely text-based, rendered procedurally by DocumentNode. The game's design deliberately treats bureaucratic text as its visual medium — illustrated case documents would contradict the aesthetic. This category is intentionally empty.

---

## 6. Marketing Assets

| Asset Name | Type | Where Used | Priority | Exists? | Notes |
|---|---|---|---|---|---|
| App icon 1024×1024 | App icon | App Store, iOS home screen, Xcode project | **Critical** | **No** — imageset exists, 0 slots filled | Xcode shows placeholder. Required for TestFlight. Required for App Store. Single most visible marketing asset. |
| App icon 180×180 (@3x iPhone) | App icon variant | iPhone home screen | **Critical** | **No** | Derived from 1024×1024 master. |
| Preview / promotional image | Marketing | Potential social / presskit | **Optional** | **No** | Not required for App Store submission. |

**Marketing assets completion: 0/2 critical (0%)**

---

## 7. App Store Assets

| Asset Name | Type | Requirement | Priority | Exists? | Notes |
|---|---|---|---|---|---|
| Screenshot 1 — Main menu | Landscape 6.9" screenshot | App Store listing | **Critical** | **No** | Requires `bg_main_menu` art to be meaningful. |
| Screenshot 2 — Desk scene with case open | Landscape 6.9" screenshot | App Store listing | **Critical** | **No** | Requires `bg_desk_office` art. Contradiction panel visible = better screenshot. |
| Screenshot 3 — Platform level | Landscape 6.9" screenshot | App Store listing | **Critical** | **No** | Requires parallax layers to be readable. `mara_silhouette` helps. |
| Screenshot 4 — Dialogue scene with portrait | Landscape 6.9" screenshot | App Store listing | **Critical** | **No** | Requires `portrait_audit_voice` to look finished. |
| Screenshot 5 — Chapter Select | Landscape 6.9" screenshot | App Store listing | **Critical** | **No** | Functional now; splash screens would improve it but not required. |
| 30-second preview video | App Store preview | Optional App Store | **Optional** | **No** | Requires completed Ch1 art pass before recording. |

**App Store asset completion: 0/5 critical (0%)**

---

## A. Assets Blocking Chapter 2 Completion

Chapter 2 is currently **playable end-to-end** with placeholder visuals. No asset is a hard blocker (the code fails gracefully for all missing assets). However, for Chapter 2 to be considered production-quality rather than a playable stub:

| Asset | Impact without it | Blocking? |
|---|---|---|
| `portrait_audit_voice` | All Ch2 dialogue shows a coloured rectangle where the portrait should be. Speaker name correct; text correct; portrait wrong. | **Soft block — functional but visually incomplete** |
| `bg_desk_office` | Ch2 desk sessions show procedural black background | No — functional |
| `bg_city_far`, `bg_facility_mid`, `bg_facility_near` | P02 platform level shows procedural building silhouettes and rain animation | No — functional |

**Hard blocks on Ch2:** None.
**Soft blocks on Ch2:** `portrait_audit_voice` only. Everything else is functional with placeholders.

---

## B. Assets Blocking Chapter 3 Implementation

Chapter 3 can be implemented (JSON written, wired, tested) without any new art. No assets block Ch3 content implementation.

For Ch3 to be production-quality when shipped:

| Asset | Why needed for Ch3 |
|---|---|
| `portrait_audit_voice` | Ch3 intro dialogue (Calyx memo pre-desk, mid-chapter cascade, post-desk) all use Audit Voice |
| `portrait_calyx` | Calyx appears in Ch3 pre-desk dialogue — portrait EXISTS ✅ |
| `bg_desk_office` | Same desk background as all chapters |

**Hard blocks on Ch3 implementation:** None.
**Recommended before Ch3 ships:** `portrait_audit_voice` (appears in every chapter dialogue).

---

## C. Assets Required Before Commercial Release

Everything in this list must exist, be approved, and be in the asset catalog before the game can be submitted to the App Store.

### Must-Have (Release Blockers)

| Asset | Category | Reason |
|---|---|---|
| `portrait_audit_voice` | Portrait | Appears in every chapter's dialogue; missing portrait is visible to every player |
| `portrait_elias_venn` | Portrait | Core emotional payoff of Ch5–Ch8; appears at major story reveals |
| `portrait_jun_vale` | Portrait | Formal approval required (file present, approval pending); Ch7–Ch8 dialogue |
| `bg_desk_office` | Background | Visible during 90%+ of total game runtime; currently procedural black |
| `bg_main_menu` | Background | First impression; required for App Store screenshots |
| `bg_chapter_complete` | Background | Appears after every chapter (8 times per playthrough) |
| `bg_city_far` | Parallax | All 8 platform levels; currently procedural |
| `bg_facility_mid` | Parallax | All 8 platform levels |
| `bg_facility_near` | Parallax | All 8 platform levels |
| `mara_silhouette` | Sprite | Player character in all 8 platform levels |
| `sprite_security_drone` | Sprite | Enemies in all 8 platform levels |
| All 6 stamp icons | UI | Action buttons in all desk scenes, all chapters |
| App icon 1024×1024 | Marketing | Required for App Store submission; TestFlight |
| 5 App Store screenshots | Marketing | Required for App Store listing |
| `bg_ending_broadcast` | Background | Required for Ending A (Broadcast) |
| `bg_ending_control` | Background | Required for Ending B (Control) |
| `bg_ending_erasure` | Background | Required for Ending C (Erasure) |

### Nice-to-Have Before Release (Quality)

| Asset | Reason |
|---|---|
| `bg_boot_screen` | 5-second screen; functional without it |
| 8 chapter splash screens | ChapterSelectScene; text titles are readable without them |
| `icon_pickup_data` | Data orbs are `◆` labels; functional |
| `icon_cartridge` | Cartridge items are `◈` labels; functional |
| `texture_document_paper` | Document overlay; currently clean white background |

---

## Top 10 Highest-Value Art Assets to Produce Next

Ranked by: (visibility × chapters affected × hours to produce × blocking status)

| Rank | Asset | Why This Rank |
|---|---|---|
| **1** | `portrait_audit_voice` | Appears in EVERY chapter's dialogue. Soft-blocking Ch2 quality. Ch3–Ch8 content is being written now — all of it requires this portrait. One generation session fixes a game-wide gap. Unique challenge (no face) means it must be generated early to allow for revisions. |
| **2** | `bg_desk_office` | The single most-seen asset in the game. A player who completes the full game spends roughly 2 hours and 20 minutes looking at this screen. Currently procedural black. Generates immediately in one DiffusionBee session. App Store screenshot 2 depends on it. |
| **3** | `bg_main_menu` | First thing every player sees. Required for App Store screenshots. Stores the game's visual identity at the entry point. One session. Generates in parallel with bg_desk_office (same settings). |
| **4** | `bg_city_far` | Single 6,144 px strip that backgrounds all 8 platform levels. Highest leverage-per-asset of any background: one generation session serves every platform level in the game. Generate in same session as PL-002 and PL-003 to ensure visual coherence. |
| **5** | `bg_facility_mid` | Same session as bg_city_far. Together, these two strips give P01 and P02 real visual identity. Cannot be generated separately — must share seed family with PL-001. |
| **6** | `mara_silhouette` | The player-controlled character. Every platform level. Currently a coloured rectangle. Players spend 5–8 minutes per platform level looking at this sprite. Generates quickly (128×192 px, nearest-neighbour). High visual impact per hour of work. |
| **7** | `bg_chapter_complete` | Appears at the end of every chapter — 8 times per complete playthrough. Currently a black screen with text. Players are emotionally primed at this moment; the background either reinforces the tone or undercuts it. One session. |
| **8** | `portrait_elias_venn` | The emotional payoff of five chapters of setup. Must be generated via img2img from portrait_mara at 0.20 strength — this should happen early to allow iteration on the sibling resemblance before the Ch5 writing phase begins. |
| **9** | All 6 stamp icons (as batch) | Every player action in every desk scene triggers a stamp animation. These are currently text labels on buttons — functional, but the visual is weaker than it should be. Six icons generated in one session (same prompt template, colour varied). Low per-asset time; high cumulative visual impact across the entire game. |
| **10** | App icon 1024×1024 | Required before any TestFlight build can be sent to external testers. Cannot submit to App Store without it. Currently the Xcode default placeholder — unprofessional in any external build. The game will not get external feedback until this exists. |

---

## Appendix: Confirmed Asset Catalog Contents (2026-06-02)

| Imageset | PNG File Present | Approval Status |
|---|---|---|
| `portrait_mara.imageset` | ✅ `portrait_mara.png` | ✅ Approved — locked |
| `portrait_calyx.imageset` | ✅ `portrait_calyx.png` | ✅ Approved — locked |
| `portrait_saint_orra.imageset` | ✅ `portrait_saint_orra.png` | ✅ Approved — locked |
| `portrait_pmca_director.imageset` | ✅ `portrait_pmca_director.png` | ✅ Approved — locked |
| `portrait_jun_vale.imageset` | ✅ `portrait_jun_vale.png` | ⚠️ Pending formal v1 confirmation |
| `AppIcon.appiconset` | ❌ 0 slots filled | ❌ Xcode placeholder |
| `portrait_audit_voice.imageset` | ❌ Imageset does not exist | ❌ Not generated |
| `portrait_elias_venn.imageset` | ❌ Imageset does not exist | ❌ Not generated |
| All background imagesets | ❌ None exist | ❌ Not generated |
| All sprite imagesets | ❌ None exist | ❌ Not generated |
| All icon imagesets | ❌ None exist | ❌ Not generated |

*Audit produced 2026-06-02. Asset catalog physically inspected — counts are exact, not estimates. All conclusions derived from file system scan + code review. No art produced.*
