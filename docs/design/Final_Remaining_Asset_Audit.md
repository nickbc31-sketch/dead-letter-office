# Dead Letter Office — Final Remaining Asset Audit

**Date:** 2026-06-07  
**Scope:** Post Chapters 4–8 content pass. Lists assets still required for release-quality presentation after Shift 1→8 is fully playable on current systems and art library.

**Playability status:** Ch4–8 cases, dialogues, levels, PDA journal entries, hack puzzles, and chapter progression are authored and build-validated. Procedural fallbacks cover all missing rasters.

---

## Summary

| Category | Critical | Recommended | Optional |
|----------|----------|-------------|----------|
| NPCs | 4 | 3 | 2 |
| Props / interactables | 2 | 6 | 4 |
| Backgrounds (parallax) | 6 | 4 | 2 |
| Effects | 1 | 3 | 2 |
| Portraits | 3 | 4 | 2 |
| Animation sets | 2 | 3 | 2 |

---

## NPCs

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `npc_jun_vale` field sprite | Ch7 | **Critical** | Jun Vale undercity encounter — procedural placeholder only |
| `npc_transit_worker` field sprite | Ch6 | **Critical** | P06 train worker — procedural placeholder |
| `npc_lina_marr` field sprite | Ch4, Ch12 callback | **Critical** | Living-sender thread; no field appearance yet but referenced in census |
| `sprite_director_calyx` (silhouette) | Ch4, Ch8 | **Critical** | Directorate presence — dialogue portrait missing |
| `npc_resident` generic | Ch3, Ch7 | Recommended | Reusable resident silhouette for undercity |
| `npc_corporate_exec` | Ch5 | Recommended | Helix Meridian corridor dressing |
| `npc_choir_contact` | Ch7 | Recommended | Quiet Choir NPC variant |
| `npc_sera_quill` desk reference | Ch5 | Optional | Case-only today |
| `npc_lena_harrow` desk reference | Ch6 | Optional | Case-only today |

---

## Props / field interactables

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `security_camera` production wiring | Ch1–8 | **Critical** | PNG in catalog; verify all levels use `FieldSpriteAssets` not procedural housing |
| `pmca_guard` / `enforcer_robot` atlas wiring | Ch4–8 | **Critical** | Assets imported; guard patrols still procedural in some levels |
| `archive_interior_dressing` set | Ch4, Ch8 | Recommended | Shelving, tape reels, revision queue props |
| `train_carriage_interior` set | Ch6 | Recommended | Carriage transitions — currently environmental text only |
| `helix_glass_partition` props | Ch5 | Recommended | Corporate corridor dressing |
| `choir_lantern` / fabric rigging | Ch7 | Recommended | Undercity warmth vs institutional cold |
| `data_cartridge` pickup animation | Ch1–8 | Recommended | Static sprite — no collect flash |
| `notice_board` variant set | Ch2–7 | Optional | Single PNG — chapter-specific notices |
| `maintenance_locker` open state | Ch1–2 | Optional | Closed sprite only |
| `keypad` pressed state | Ch3+ | Optional | Single frame today |

---

## Backgrounds (parallax)

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `bg_annex_mid` / `bg_annex_near` | Ch4 | **Critical** | Indoor archive — currently `bg_facility_*` fallback |
| `bg_meridian_mid` / `bg_meridian_near` | Ch5 | **Critical** | Helix corporate interior — facility fallback |
| `bg_train_mid` / `bg_train_near` | Ch6 | **Critical** | Train infrastructure — facility fallback |
| `bg_undercity_mid` / `bg_undercity_near` | Ch7 | **Critical** | Quiet Choir — facility fallback |
| `bg_central_archive_mid` / `bg_central_archive_near` | Ch8 | **Critical** | Central Archive — facility fallback |
| `bg_housing_mid` / `bg_housing_near` | Ch3 | **Critical** | Referenced in `level_ch3.json`; may still fallback |
| `bg_city_far` seam fix art | Ch1–3 exterior | Recommended | Parallax seam pass done in code; art can reduce repeat visibility |
| `bg_facility_interior_static` | Ch4, Ch8 | Recommended | Single-layer indoor variant without city far |
| `bg_relay_building_interior` | Ch1 interior | Optional | Interior levels use procedural dressing |
| `bg_sorting_centre_detail` | Ch2 | Optional | Mid-layer depth for Ch2 |

---

## Effects

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `ambient_desk` + chapter ambient tracks | Ch1–8 | **Critical** | Many `ambient_*` references missing from bundle — silence or fallback |
| `stamp.wav` / `page_turn.wav` | Desk | Recommended | Desk SFX pass incomplete |
| `ambient_platform_train` | Ch6 | Recommended | Referenced in `chapters.json` |
| `ambient_desk_tense` / `ambient_desk_final` | Ch4, Ch8 | Recommended | Chapter mood tracks |
| `hack_success.wav` / `hack_fail.wav` | PDA hacks | Optional | Visual-only feedback today |
| `camera_alert.wav` | Field | Optional | Detection feedback |

---

## Portraits

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `portrait_director_calyx` | Ch4, Ch8 | **Critical** | C14, C24 dialogue — falls back to audit voice or blank |
| `portrait_jun_vale` | Ch7 | **Critical** | Approved source may exist — verify catalog wiring |
| `portrait_saint_orra` | Ch6–8 | **Critical** | Orra thread climax |
| `portrait_lina_marr` | Ch4, Ch12 | Recommended | Living sender case |
| `portrait_elias_venn` | Ch5–8 | Recommended | Approved PNG in repo — verify `portrait_elias_venn` imageset |
| `portrait_lena_harrow` | Ch6 | Recommended | Trial termination case |
| `portrait_sera_quill` | Ch5 | Optional | Legacy edit case |
| `portrait_executive_pell` | Ch5 | Optional | Three-ending case |

---

## Animation sets

| Asset | Chapters | Priority | Notes |
|-------|----------|----------|-------|
| `pmca_guard` walk / idle atlas | Ch4–8 | **Critical** | Single PNG — no directional patrol animation |
| `enforcer_robot` patrol atlas | Ch8 | **Critical** | Central Archive climax |
| `security_camera` pan animation | Ch1–8 | Recommended | Static sprite — cone is code-driven |
| `Mara` PDA journal open animation | Ch1–8 | Recommended | Static PDA overlay |
| `terminal_screen` flicker frames | Field | Optional | Text panel is UI overlay |
| `cartridge` float / pickup | Field | Optional | |

---

## Remaining blockers to release

1. **Audio bundle gaps** — `ambient_desk`, `ambient_platform`, chapter-specific tracks referenced in JSON but not all present in `Audio/` folder.
2. **Chapter parallax art** — Ch3–8 field levels use `bg_facility_*` or missing housing layers; indoor chapters should not show city skyline (partially addressed in level JSON).
3. **Portrait gaps for climax cast** — Calyx, Orra, Jun in dialogue without approved portrait imagesets.
4. **NPC field sprites** — Jun Vale and transit worker are high-visibility encounters on procedural placeholders.
5. **Full playthrough QA** — Consequence chain C01→C09→C12, Elias C04→C15→C18→C23, Orra C19→C24 needs end-to-end playtest on device.
6. **C13 stamp-lock** — Optional design doc mechanic (all docs open before stamp) not implemented; cases playable without it.

---

## Recommended next production step

**Priority 1:** Generate and import the five chapter-specific parallax pairs (`bg_annex_*`, `bg_meridian_*`, `bg_train_*`, `bg_undercity_*`, `bg_central_archive_*`) — highest visual impact per hour, unblocks indoor identity for Shifts 4–8.

**Priority 2:** Wire `portrait_director_calyx`, `portrait_saint_orra`, and `portrait_jun_vale` into `Assets.xcassets` — unblocks narrative climax presentation at desk and platform end dialogues.

**Priority 3:** Complete desk/platform ambient audio pass — add missing `ambient_*` tracks referenced in `chapters.json` and level JSON so Shifts 4–8 have mood audio.

---

## Estimated playtime (Shift 1 → 8)

| Segment | Estimate |
|---------|----------|
| Desk cases (24 cases) | ~90–120 min |
| Field investigation (8 levels) | ~24–40 min (~3–5 min each) |
| Dialogues + shift evaluations | ~20–30 min |
| **Total** | **~2.5–3.5 hours** |

---

*Audit completed after Chapters 4–8 content pass. Build: **BUILD SUCCEEDED** (generic iOS Simulator, 2026-06-07).*
