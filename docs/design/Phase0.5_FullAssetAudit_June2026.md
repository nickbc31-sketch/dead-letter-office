# Phase 0.5 — Full Asset Audit

**Dead Letter Office** | Canonical production reference  
**Status:** Approved 2026-06-05  
**Authority:** `CANON.md`, `ArtStyleGuide.md`, `AssetProductionPlan.md`, approved Ch4–8 blueprint  
**Catalog inspected:** `DeadLetterOffice/Assets.xcassets`  
**Next gate:** Phase 0 complete → Chapter 4 engineering

---

## Approved design constraints

- Platform sections: **3–5 minutes maximum** per level
- **P06 train scope reduced** (2 carriages + siding)
- **Ch7 = most dialogue-heavy** chapter (portrait/dialogue priority)
- **Ch8 climax = desk C24 stamp**, not platform (P08 is infiltration/setup only)

## Placeholder status key

| Status | Meaning |
|--------|---------|
| **Locked** | Approved canon in catalog — do not regenerate |
| **In catalog** | PNG present, playable |
| **Procedural OK** | Missing asset; code renders fallback (no crash) |
| **Must create** | Required for production-quality ship |
| **Optional** | Polish / store / deferred |

## Priority key

| Tier | Meaning |
|------|---------|
| **P0** | Blocks Ch4 production-quality start |
| **P1** | Needed before chapter ships |
| **P2** | Polish pass |
| **P3** | Post-launch / deferred |

---

## A. Global Reusable Assets

### A1. Character Portraits (DialogueScene)

Standard: **392×392 px @2x**, 1:1. Authority: `ArtStyleGuide.md`, `PortraitStyleReference.md`.

| Asset name | Character | Purpose | Dimensions | Priority | Placeholder status |
|------------|-----------|---------|------------|----------|-------------------|
| `portrait_mara` | Mara Venn | Protagonist Ch1–8 | 392×392, 1:1 | P0 | **Locked** — in catalog |
| `portrait_calyx` | Director Calyx | Antagonist Ch1, 3–4, 7–8 | 392×392, 1:1 | P0 | **Locked** — in catalog |
| `portrait_audit_voice` | Audit Voice | Every chapter intro | 392×392, 1:1 | P0 | **In catalog** |
| `portrait_pmca_director` | PMCA Director | Authority Ch4–6 | 392×392, 1:1 | P1 | **Locked** — in catalog |
| `portrait_jun_vale` | Jun Vale | Resistance Ch2+ / Ch7–8 | 392×392, 1:1 | P0 | **In catalog** |
| `portrait_saint_orra` | Saint Orra | Ch6, Ch8 C24 | 392×392, 1:1 | P1 | **Locked** — in catalog |
| `portrait_elias_venn` | Elias Venn | Ch5–8 Elias thread | 392×392, 1:1 | P0 | **Locked** — in catalog (`elias_venn_v1_approved.png`) |

Case-only senders: **Procedural OK** (colour-hash placeholder).

**Completion: 7/7 in catalog.**

---

### A2. Scene Backgrounds (Full-screen)

| Asset name | Scene | Purpose | Dimensions | Priority | Placeholder status |
|------------|-------|---------|------------|----------|-------------------|
| `bg_desk_office` | DeskScene | Desk backdrop Ch1–8 | 2668×1500, 16:9 | P0 | **Must create** |
| `bg_terminal_wallpaper` | DeskScene | Interim desk atmosphere | 2668×1500, 16:9 | P1 | **In catalog** |
| `bg_main_menu` | MainMenuScene | First impression | 2668×1500, 16:9 | P0 | **In catalog** |
| `bg_chapter_complete` | ChapterCompleteScene | Post-chapter (×8) | 2668×1500, 16:9 | P1 | **Procedural OK** |
| `bg_boot_screen` | BootScene | Boot (~5s) | 2668×1500, 16:9 | P3 | **Procedural OK** |
| `bg_ending_broadcast` | EndingScene A | Broadcast | 2668×1500, 16:9 | P2 | **Procedural OK** |
| `bg_ending_control` | EndingScene B | Control | 2668×1500, 16:9 | P2 | **Procedural OK** |
| `bg_ending_erasure` | EndingScene C | Erasure | 2668×1500, 16:9 | P2 | **Procedural OK** |

---

### A3. Platform Parallax Backgrounds (Global base)

| Asset name | Layer | Purpose | Dimensions | Priority | Placeholder status |
|------------|-------|---------|------------|----------|-------------------|
| `bg_city_far` | Far (0.1) | Skyline all levels | 6144×800 | P0 | **Procedural OK** |
| `bg_facility_mid` | Mid (0.4) | Industrial mid-ground | 6144×800 | P0 | **Procedural OK** |
| `bg_facility_near` | Near (0.7) | Pipes; upper 50% alpha | 6144×800 | P0 | **Procedural OK** |

---

### A4. Platform Character Sprites

| Asset name | Purpose | Dimensions | Priority | Placeholder status |
|------------|---------|------------|----------|-------------------|
| `mara_silhouette` | Player | 128×192, 2:3 | P1 | **Procedural OK** |
| `sprite_security_drone` | Drone enemy | 128×96, 4:3 | P2 | **Procedural OK** |
| `sprite_security_guard` | Guard enemy | 128×128 | P2 | **Procedural OK** |

---

### A5. UI Assets

| Asset name | Purpose | Dimensions | Priority | Placeholder status |
|------------|---------|------------|----------|-------------------|
| `icon_stamp_approved` | APPROVE | 128×128 | P2 | **Procedural OK** |
| `icon_stamp_rejected` | REJECT | 128×128 | P2 | **Procedural OK** |
| `icon_stamp_censored` | CENSOR | 128×128 | P2 | **Procedural OK** |
| `icon_stamp_forward` | ILLEGAL FORWARD | 128×128 | P2 | **Procedural OK** |
| `icon_stamp_archive` | ARCHIVE | 128×128 | P2 | **Procedural OK** |
| `icon_stamp_flag` | FLAG ANOMALY | 128×128 | P2 | **Procedural OK** |
| `icon_pickup_data` | Data pickup | 64×64 | P3 | **Procedural OK** |
| `icon_cartridge` | Cartridge | 64×64 | P3 | **Procedural OK** |
| `texture_document_paper` | Document overlay | 512×768 | P2 | **Procedural OK** |
| `AppIcon` | Store / home screen | 1024×1024 | P0 (store) | **In catalog** |

Virtual pad, thumbstick, CRT: **procedural — no assets**.

---

### A6. Chapter Splashes

| Asset name | Purpose | Dimensions | Priority | Placeholder status |
|------------|---------|------------|----------|-------------------|
| `splash_ch1` … `splash_ch8` | Chapter Select thumbnails | 512×256 each | P3 | **Procedural OK** |

---

### A7. Audio — Global

**Bundle: 0 files** (silent-fail). Music: **MP3**; SFX: **WAV**.

#### Music

| Asset name | Purpose | Priority | Wired | Placeholder |
|------------|---------|----------|-------|-------------|
| `ambient_desk.mp3` | Desk default | P0 | Yes | Missing |
| `ambient_menu.mp3` | Main menu | P0 | Yes | Missing |
| `ambient_platform.mp3` | Platform fallback | P0 | Yes | Missing |
| `ambient_boot.mp3` | Boot | P2 | Yes | Missing |
| `chapter_complete.mp3` | Chapter complete | P1 | Yes | Missing |
| `ambient_ending.mp3` | Endings | P1 | Yes | Missing |

#### Core SFX (wired)

| Asset name | Purpose | Priority | Placeholder |
|------------|---------|----------|-------------|
| `stamp.wav` | Stamp actions | P0 | Missing |
| `page_turn.wav` | Tab switch | P0 | Missing |
| `terminal_beep.wav` | Terminal | P1 | Missing |
| `drone_alert.wav` | Drone catch | P1 | Missing |

#### Global SFX (not wired)

| Asset name | Purpose | Priority |
|------------|---------|----------|
| `sfx_emp_pulse.wav` | EMP fire | P1 |
| `dead_letter_arrival.wav` | Case arrival | P1 |
| `glitch_im_not_dead.wav` | C05 climax | P1 |
| `data_cartridge_pickup.wav` | Pickup | P2 |
| `door_unlock.wav` | Door open | P2 |

---

## B. Chapter-Specific Assets

### Ch1 — Orientation
- Parallax trio for P01 — **Procedural OK**
- Data in repo — **complete**

### Ch2 — Misfiled Living
- Global parallax P02 — **Procedural OK**
- `portrait_jun_vale` wire in dialogue — P1

### Ch3 — Daughter Clause
- `bg_housing_mid`, `bg_housing_near` — **Must create** (referenced in `level_ch3.json`)
- `bg_city_far` — **Procedural OK**

### Ch4 — Ghost Audit
- Scanner beam — **code-driven, Procedural OK**
- `ambient_desk_tense.mp3` — P1, missing
- `sfx_scanner_flag.wav`, `sfx_emp_pulse.wav` — P1
- Optional `bg_annex_mid` — P2

### Ch5 — Afterlife Premium
- `portrait_elias_venn` — **In catalog** (locked)
- `bg_meridian_mid` — P1 must create
- `ambient_meridian.mp3` — P1

### Ch6 — Black Mail Train (reduced)
- `bg_train_mid` — P1 must create
- `ambient_platform_train.mp3` — P1
- `sfx_train_door.wav`, `glitch_orra_fragment.wav` — P1

### Ch7 — Choir Beneath (dialogue-heavy)
- `ambient_choir.mp3` — **P0 must create**
- `portrait_jun_vale`, `portrait_elias_venn` — in catalog (wire in dialogue when Ch5–7 content ships)
- `bg_undercity_mid` — P1
- Platform minimal (~2,500–3,500 pt)

### Ch8 — Dead Letter Office (desk climax)
- C24 desk — procedural documents
- `ambient_desk_final.mp3` — P1
- P08 infiltration only (~3,000–3,500 pt)
- `bg_central_archive_mid` — P1

---

## Ch4 asset gate (before implementation)

- [ ] Session 1 audio (`ambient_desk`, `stamp`, `page_turn`, `ambient_platform`)
- [ ] Desk background decision: `bg_terminal_wallpaper` vs `bg_desk_office`
- [ ] Parallax: procedural v1 or PL-001–003 batch
- [ ] `ambient_desk_tense` + EMP/drone SFX sourced
- [x] Phase 0.5 audit approved (this document)

---

## Audio sourcing sessions

| Session | Assets | Unblocks |
|---------|--------|----------|
| 1 | desk, menu, platform, stamp, page_turn | Core playtest |
| 2 | chapter_complete, terminal_beep, drone_alert, emp_pulse | Platform |
| 3 | desk_tense, glitch, dead_letter_arrival | Ch4 narrative |
| 4 | meridian, platform_train | Ch5–6 |
| 5 | choir, desk_final, ending | Ch7–8 |

---

*Approved 2026-06-05. Supersedes informal June 2026 visual audit counts where catalog state differed (e.g. `portrait_audit_voice`, `bg_main_menu` now in catalog).*
