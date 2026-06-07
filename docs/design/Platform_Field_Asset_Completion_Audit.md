# Dead Letter Office — Platform / Field Graphics Asset Completion Audit

**Date:** 2026-06-07  
**Scope:** Visual assets for field investigation sections (Chapters 1–8). Audio, narrative, and gameplay logic are out of scope.  
**Pivot context:** Field sections are investigation-first (terminals, PDA notes, environmental story, drones/cameras/enforcers, security bypass, light puzzles) — not platforming, combat, or precision jumping.

**Sources read:**
- `docs/PROJECT_STATUS_JUNE_2026.md` (stale in places — catalog counts predate June art pass)
- `docs/design/VisualAssetAudit_June2026.md`
- `docs/AssetProductionPlan.md`
- `docs/CANON.md`
- `docs/Phase0.6_GlobalAssetProductionPack.md`
- `docs/design/Phase0.5_FullAssetAudit_June2026.md`
- `docs/SESSION_HANDOVER_2026_06_05.md`
- `ART_BRIEF_CH1_CH3.md`
- Code: `PlatformScene.swift`, `Platform/`, `UI/`, `Data/Levels/`

**Bible note:** `docs/Dead_Letter_Office_Definitive_Project_Bible_v4_FULL.docx` was not present in the workspace at audit time.

---

## Executive summary

| Metric | Count |
|--------|-------|
| Field levels in repo | 5 (`level_ch1`, `level_ch2`, `level_ch3`, + 2 Ch1 interiors) |
| Field levels planned (Ch4–8) | 5 (`level_ch4`–`level_ch8` — JSON not yet authored) |
| Raster assets in `Assets.xcassets` used by field scenes | 14 imagesets + 2 sprite atlases |
| Procedural / code-drawn field visuals still in active use | ~85% of interactables, NPCs (except Haas), guards, cameras, buildings, signs |
| **Tier 1 gaps blocking Ch2–3 polish** | 12 asset families |
| **Assets present but unused** | 2 (`platform_gantry_v1`, `pmca_drone_v1` as primary) |

**Recommended next asset to generate:** `bg_housing_mid` + `bg_housing_near` (Ch3 level JSON already references them; current fallback is random procedural skyline).

---

## Task 1 — Current field asset inventory

Status key: **Final** = shipped art in catalog and wired · **Placeholder** = procedural/code-drawn but functional · **Missing** = referenced or required, not in catalog · **Fallback** = present, used only when primary fails · **Needs replacement** = works but visibly below production bar

### A. Player character

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `Mara.atlas` (49 frames) | `DeadLetterOffice/Mara.atlas/` | `MaraAnimationController` → `MaraPlayerNode` | Ch1–8 | **Final** | idle, walk, PDA, terminal, hack, scan, EMP states |
| Source sprites | `assets/assets/Sprites/mara_venn_sprites/` | Source-of-truth PNGs for atlas | Ch1–8 | **Final** | Mirror of atlas frames |
| `mara_silhouette` | `Assets.xcassets/mara_silhouette.imageset/` | `MaraAnimationController` fallback | Ch1–8 | **Fallback** | Used only if atlas preload fails |
| `assets/assets/Sprites/mara_silhouette.png` | Source folder | Not directly wired | — | **Present, unused** | Duplicate of catalog silhouette |

### B. NPC field sprites

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `K_haas.atlas` (20 frames) | `DeadLetterOffice/K_haas.atlas/` | `WorkerKHaasNode` → `PlatformScene.buildNPC` (`npc.id == "haas"`) | Ch1 | **Final** | idle / beckon / worried |
| Source: `k_haas_*.png` | `assets/assets/Sprites/k_haas/` | Atlas source | Ch1 | **Final** | |
| Procedural NPC silhouette | Code: `buildPlaceholderNPC` | `maint_worker_12` (Ch2), `resident_305` (Ch3), future NPCs | Ch2–8 | **Placeholder** | Coloured rectangles + `?` indicator |
| `npc_maintenance` / `npc_resident` (brief) | `ART_BRIEF_CH1_CH3.md` | Not implemented | Ch2–3 | **Missing** | Brief exists; no imageset or atlas |

### C. Security / hazard sprites

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `drone_side_left` | `Assets.xcassets/drone_side_left.imageset/` | `DroneEnemyNode` | Ch1–8 | **Final** | Horizontal patrol, velocity.x < 0 |
| `drone_side_right` | `Assets.xcassets/drone_side_right.imageset/` | `DroneEnemyNode` | Ch1–8 | **Final** | Horizontal patrol, velocity.x > 0 |
| `drone_down` | `Assets.xcassets/drone_down.imageset/` | `DroneEnemyNode` | Ch1–8 | **Final** | Vertical patrol + pause on vertical segment |
| Source: `assets/assets/Sprites/drone/` | Source folder | Import source | Ch1–8 | **Final** | |
| `pmca_drone_v1` | `Assets.xcassets/pmca_drone_v1.imageset/` | `DroneEnemyNode` fallback chain | Ch1–8 | **Fallback** | Legacy single sprite; directional art supersedes |
| Procedural drone silhouette | `DroneEnemyNode.buildSprite` fallback | When no texture resolves | Ch1–8 | **Placeholder** | Teal body + pulsing lights |
| Procedural guard silhouette | `DroneEnemyNode.buildGuardSprite` | `enemyType: security_guard` patrols | Ch1–3 | **Placeholder** | Humanoid rects + red armband; no sprite asset |
| `sprite_security_guard` | Not in catalog | — | Ch4–8 | **Missing** | Listed Phase D in production pack |
| Procedural scan cone | `DroneEnemyNode` / guard variant | Detection visual | Ch1–8 | **Final (code)** | Amber/danger `SKShapeNode`; no texture needed |
| Procedural EMP pulse rings | `MaraPlayerNode` | EMP fire visual | Ch1–8 | **Final (code)** | Expanding `SKShapeNode` rings; no sprite sheet required |
| Stun tint overlay | `DroneEnemyNode.stun` | EMP-disabled drone state | Ch1–8 | **Final (code)** | Teal colorize + faded cone |

### D. Security cameras

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| Procedural camera housing | `SecurityCameraNode.buildVisual` | `securityCameras` in level JSON | Ch1–3 | **Placeholder** | Grey box + lens circle + scan cone |
| `security_camera_wall_v1` | Not in catalog | — | Ch1–8 | **Missing** | Replace procedural housing; cone stays code-driven |

**Active camera placements:** `ch1_checkpoint_cam`, `ch2_restricted_cam`, `ch3_block_c_cam`

### E. Enforcement / field boundary

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| Procedural enforcer robot | `FieldInvestigationVisuals.enforcementRobot` | `PlatformScene.buildFieldBoundary` | Ch1–3 | **Placeholder** | All three field levels define `fieldBoundaryX` |
| `enforcer_robot_v1` | Not in catalog | — | Ch1–8 | **Missing** | Distinct from patrol guard; blocks unauthorised zone |

### F. Background / parallax layers

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `bg_city_far` | `Assets.xcassets/bg_city_far.imageset/` | `level_ch1/2/3` `backgroundLayers` | Ch1–3 (+ Ch4–8 default) | **Final** | scroll 0.1, nearest filter |
| `bg_facility_mid` | `Assets.xcassets/bg_facility_mid.imageset/` | Ch1–2 mid layer | Ch1–2, Ch4 default | **Final** | scroll 0.4 |
| `bg_facility_near` | `Assets.xcassets/bg_facility_near.imageset/` | Ch1–2 near layer | Ch1–2, Ch4 default | **Final** | scroll 0.7, alpha feather |
| `bg_housing_mid` | **Not in catalog** | `level_ch3.json` references | Ch3 | **Missing** | Falls back to procedural random skyline |
| `bg_housing_near` | **Not in catalog** | `level_ch3.json` references | Ch3 | **Missing** | Falls back to procedural |
| `bg_meridian_mid` | Not in catalog | Planned Ch5 desk/atmosphere | Ch5 | **Missing** | Phase C |
| `bg_train_mid` | Not in catalog | Planned `level_ch6` | Ch6 | **Missing** | Phase C |
| `bg_undercity_mid` | Not in catalog | Planned `level_ch7` | Ch7 | **Missing** | Phase C |
| `bg_central_archive_mid` | Not in catalog | Planned Ch8 infiltration | Ch8 | **Missing** | Phase C |
| `bg_annex_mid` | Not in catalog | Optional Ch4 Ghost Audit | Ch4 | **Missing** | P2 optional |
| Procedural parallax fallback | `PlatformScene.buildProceduralBackground` | When `UIImage(named:)` fails | Any | **Placeholder** | Random building rects + rain |
| Source duplicates | `assets/assets/Backgrounds/` | Not imported | — | **Present, unused** | `BG_facility_*_v1.png`, `bg_city_far.png` — use catalog names on import |

### G. Ground / road / floor

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `ground_industrial_road_v1` | `Assets.xcassets/ground_industrial_road_v1.imageset/` | `PlatformScene.buildFloor` tiled | Ch1–3 | **Final** | Linear filter; 40pt ground band |
| `ground_housing_corridor_v1` | Not in catalog | — | Ch3+ | **Missing** | Optional warmer floor variant for P03 |
| `ground_train_platform_v1` | Not in catalog | — | Ch6 | **Missing** | Rail siding floor |
| `ground_archive_tile_v1` | Not in catalog | — | Ch4/8 | **Missing** | Records annex / central archive |
| Procedural floor fill | `buildFloor` fallback | Missing road texture | Any | **Placeholder** | Flat `platformSilhouette` colour |

### H. Walkway / gantry (optional elevation)

| Filename | Location | Used in | Chapters | Status | Notes |
|----------|----------|---------|----------|--------|-------|
| `platform_gantry_v1` | `Assets.xcassets/platform_gantry_v1.imageset/` | `PlatformScene.addPlatform` | **None** | **Present, unused** | Code profile exists; no `platformNodes` in any level JSON |
| Procedural platform strip | `addPlatform` fallback | Empty `platformNodes` everywhere | — | **N/A** | Investigation pivot de-emphasises gantries |

### I. Buildings (exterior shells)

| Asset | Location | Used in | Chapters | Status | Notes |
|-------|----------|---------|----------|--------|-------|
| Procedural `relay_depot` | `PlatformBuildingVisuals` | Ch1 relay building | Ch1 | **Placeholder** | Functional industrial shell + signage labels |
| Procedural `checkpoint` | `PlatformBuildingVisuals` | Ch1 checkpoint building | Ch1 | **Placeholder** | Taller fortified preset |
| Procedural `generic` | `PlatformBuildingVisuals` | Default preset | Future | **Placeholder** | |
| `building_relay_depot_v1` | Not in catalog | — | Ch1, reusable | **Missing** | Optional sprite replacement for procedural shell |
| `building_checkpoint_gate_v1` | Not in catalog | — | Ch1+, Ch4 | **Missing** | |

### J. Interior environments

| Asset | Location | Used in | Chapters | Status | Notes |
|-------|----------|---------|----------|--------|-------|
| Procedural interior shell | `PlatformScene.buildInteriorShell` | `isInterior: true` levels | Ch1 interiors | **Placeholder** | Flat metal back wall + ceiling |
| `PlatformInteriorVisuals` decor | Code | `level_ch1_relay_interior`, `level_ch1_checkpoint_interior` | Ch1 | **Placeholder** | Racks, lockers, notices, doors |
| `FieldEnvironmentDecor` | Code | Ch1–3 exterior dressing | Ch1–3 | **Placeholder** | Masts, barriers, dumpsters, apartment facades, etc. |
| `bg_facility_mid` (static) | Catalog | Interior `backgroundLayers` | Ch1 interiors | **Final** | Non-scrolling backdrop |

### K. Interactable props (field)

All built by `FieldInvestigationVisuals` unless noted. Labels hidden when procedural visual present (`sprite.alpha = 0`).

| Prop | Code factory | Level usage | Chapters | Status | Notes |
|------|--------------|-------------|----------|--------|-------|
| PMCA field terminal | `pmcaFieldTerminal()` | Terminals, decor kiosks | Ch1–3 | **Placeholder** | Procedural kiosk; high visibility |
| Public notice board | `publicNoticeBoard()` | `information_node` / signs | Ch2–3 | **Placeholder** | |
| Network access / PDA port | `networkAccessNode()` | `security_override` | Ch1–3 | **Placeholder** | Hack targeting visual |
| Data cache / cartridge | `dataCacheUnit()` | `cartridge`, pickups | Ch1–3 | **Placeholder** | |
| Maintenance locker | `maintenanceCabinet()` | `cabinet` | Ch2–3 | **Placeholder** | |
| Door / keypad | Procedural in `PlatformInteriorVisuals` + door barriers in scene | `door` interactables | Ch1–3 | **Placeholder** | |
| Ladder | Hidden label only | Not in current levels | Ch4+ | **Placeholder** | Type exists; no art |
| Environmental text | `SKLabelNode` Menlo | `environmentalTextNodes`, floating signs | Ch1–3 | **Final (text)** | By design — no texture |
| Objective header | HUD `objectiveText` | All field levels | Ch1–8 | **Final (text)** | e.g. "SHIFT 1 — RELAY SECTOR" |

### L. Pickups / evidence

| Asset | Location | Used in | Chapters | Status |
|-------|----------|---------|----------|--------|
| `dataCartridgePedestal()` | Code | `buildPickup`, Ch1 `pickup_01` | Ch1–3 | **Placeholder** |
| `icon_cartridge` / `icon_pickup_data` | Not in catalog | — | Ch1–8 | **Missing** (Phase D) |

### M. PDA / hack / UI overlays (field-adjacent)

| Asset | Location | Used in | Status | Notes |
|-------|----------|---------|--------|-------|
| `PDAJournalPanel` | Code/UI | Platform + Desk PDA | **Final (UI)** | Procedural panels, no raster icons |
| `PDAHackPanel` | Code/UI | Security override puzzles | **Final (UI)** | Frequency tuner / credential UI — procedural |
| `VirtualPadNode` | Code/UI | Thumbstick + EMP/Jump/Interact | **Final (UI)** | Procedural; no sprite sheet |
| `InteractButtonNode` | Code/UI | Context interact prompts | **Final (UI)** | Text labels |
| Content panel overlay | `PlatformScene.showContentPanel` | Terminals, NPC dialogue | **Final (UI)** | Terminal-style text box |
| CRT scanlines | `CRTEffectNode` | Portrait/dialogue only | **N/A field** | |

### N. Signage / faction marks

| Asset | Implementation | Chapters | Status |
|-------|----------------|----------|--------|
| PMCA sector signs | Text nodes + building signage | Ch1–3 | **Text only** |
| Helix Meridian tier signs | Ch2 `sign_tier2` etc. | Ch2 | **Text only** |
| Quiet Choir graffiti/mark | Interior scratched tag (`PlatformInteriorVisuals`) | Ch1 | **Placeholder text** |
| `sign_pmca_street_v1`, `sign_helix_meridian_v1`, `graffiti_quiet_choir_v1` | Not in catalog | Ch2–7 | **Missing** | Optional world dressing sprites |

### O. Approved portraits (dialogue — not field sprites, listed for boundary)

All in `Assets.xcassets/portrait_*.imageset/` — used in `DialogueScene`, not field walkabouts. Field audit notes: portraits do not substitute for NPC field sprites.

---

## Task 2 — Remaining required platform/field assets (Ch1–8)

### A. Core reusable field assets

| Asset | Suggested filename | Folder | Dimensions | Type | Integration target | Replaces |
|-------|-------------------|--------|------------|------|-------------------|----------|
| PMCA terminal kiosk | `pmca_terminal_kiosk_v1.png` | `assets/assets/props/` | 68×96 px @2x | Static | `FieldInvestigationVisuals.pmcaFieldTerminal()` | Procedural kiosk |
| Wall terminal (interior) | `pmca_terminal_wall_v1.png` | `assets/assets/props/` | 80×72 px @2x | Static | `PlatformInteriorVisuals.consoleDesk` | Procedural console |
| Notice board | `pmca_notice_board_v1.png` | `assets/assets/props/` | 76×88 px @2x | Static | `publicNoticeBoard()` | Procedural posts |
| Checkpoint gate (exterior) | `building_checkpoint_gate_v1.png` | `assets/assets/props/` | 320×264 px @2x | Static | `PlatformBuildingVisuals.buildCheckpoint` | Procedural checkpoint |
| Relay depot (exterior) | `building_relay_depot_v1.png` | `assets/assets/props/` | 480×168 px @2x | Static | `PlatformBuildingVisuals.buildRelayDepot` | Procedural depot |
| Security camera | `security_camera_wall_v1.png` | `assets/assets/props/` | 36×72 px @2x | Static | `SecurityCameraNode.buildVisual` | Procedural housing |
| Data uplink / relay cabinet | `relay_cabinet_v1.png` | `assets/assets/props/` | 116×176 px @2x | Static | `PlatformInteriorVisuals.addEquipmentRack` | Procedural rack |
| Maintenance cabinet | `maintenance_locker_v1.png` | `assets/assets/props/` | 52×128 px @2x | Static | `maintenanceCabinet()` / interior lockers | Procedural locker |
| Sealed / archive door | `door_sealed_archive_v1.png` | `assets/assets/props/` | 88×152 px @2x | Static | `fortifiedDoor()` / door interactables | Procedural door |
| Access keypad panel | `access_keypad_v1.png` | `assets/assets/props/` | 28×36 px @2x | Static | Door backdrop overlay | Procedural keypad |
| Portable file / cartridge | `prop_data_cartridge_v1.png` | `assets/assets/props/` | 32×32 px @2x | Static | `dataCacheUnit()` | Procedural crate |
| Evidence marker | `prop_evidence_marker_v1.png` | `assets/assets/props/` | 24×24 px @2x | Static | Future pickup variant | — |
| Cable / hack port | `pda_hack_port_v1.png` | `assets/assets/props/` | 48×80 px @2x | Static | `networkAccessNode()` | Procedural port |
| PDA scan observe effect | — | — | — | **Code only** | `MaraAnimationController` `scan_observe_*` | **Exists** in Mara atlas |
| EMP pulse effect | — | — | — | **Code only** | `MaraPlayerNode` ring pulse | **Exists** — no sprite required |
| Warning light | `prop_warning_beacon_v1.png` | `assets/assets/props/` | 12×12 px @2x | Static 2-frame blink optional | Building roof lights | Procedural rects |
| Door lock indicator | `icon_door_locked_v1.png` | `assets/assets/ui/` | 16×16 px @2x | Static | Door interactable overlay | Text/icon label |
| Surveillance sign | `sign_surveillance_v1.png` | `assets/assets/props/` | 64×40 px @2x | Static | `FieldEnvironmentDecor` | — |
| PMCA street sign | `sign_pmca_sector_v1.png` | `assets/assets/props/` | 96×48 px @2x | Static | Environmental decor | Text-only signs |
| Helix Meridian sign | `sign_helix_meridian_v1.png` | `assets/assets/props/` | 96×48 px @2x | Static | Ch2 tier signage decor | Text-only |
| Quiet Choir mark | `graffiti_quiet_choir_v1.png` | `assets/assets/props/` | 48×32 px @2x | Static | Ch7 undercity decor | Text scratch |

### B. Background / environment sets

| Environment family | Far layer | Mid layer | Near layer | Ground | Interactive props | Chapters |
|-------------------|-----------|-----------|------------|--------|-------------------|----------|
| **Relay / sorting sector** | `bg_city_far` ✅ | `bg_facility_mid` ✅ | `bg_facility_near` ✅ | `ground_industrial_road_v1` ✅ | Terminals, relay depot, drones | Ch1–2, Ch4 default |
| **Transit corridor** | `bg_city_far` ✅ | `bg_facility_mid` ✅ | `bg_facility_near` ✅ | `ground_industrial_road_v1` ✅ | Conveyors (decor), tier signs, cabinets | Ch2 |
| **Block P03 residential** | `bg_city_far` ✅ | `bg_housing_mid` ❌ | `bg_housing_near` ❌ | `ground_housing_corridor_v1` ❌ | Apartment facade, sealed unit door, mailbox row, directory | Ch3 |
| **Apartment interior** | — | `bg_housing_interior_mid` ❌ | — | `ground_housing_tile_v1` ❌ | Sealed door, terminal, evidence | Ch3 (future interior) |
| **PMCA archive / annex** | `bg_city_far` ✅ | `bg_annex_mid` ❌ (opt) / `bg_facility_mid` | `bg_facility_near` ✅ | `ground_archive_tile_v1` ❌ | Scanner zones, archive cabinets, sealed records | Ch4, Ch8 |
| **Helix Meridian service** | `bg_city_far` ✅ | `bg_meridian_mid` ❌ | `bg_meridian_near` ❌ (opt) | `ground_meridian_floor_v1` ❌ | Premium terminals, glass partitions | Ch5 (desk-primary; field minimal) |
| **Black Mail Train / rail** | `bg_city_far` ✅ | `bg_train_mid` ❌ | `bg_train_near` ❌ (opt) | `ground_train_platform_v1` ❌ | Carriage doors, timed door, cargo cache | Ch6 |
| **Quiet Choir underground** | — | `bg_undercity_mid` ❌ | `bg_undercity_near` ❌ (opt) | `ground_undercity_earth_v1` ❌ | Handmade shelters, Choir marks, warm lanterns | Ch7 |
| **Central PMCA / DLO interior** | — | `bg_central_archive_mid` ❌ | `bg_central_archive_near` ❌ (opt) | `ground_archive_tile_v1` ❌ | Final terminal, audit gate | Ch8 infiltration |

### C. NPC field sprites

| NPC | Field sprite needed | Animations | Priority | Chapters |
|-----|---------------------|------------|----------|----------|
| Worker K. Haas | ✅ `K_haas.atlas` | idle, beckon, worried | Done | Ch1 |
| Maintenance worker (SVC-19-4A) | `npc_maintenance_worker` atlas | idle, talk (min) | **Tier 1** | Ch2 |
| Resident informant (Unit 305) | `npc_resident_informant` atlas | idle, talk, worried | **Tier 1** | Ch3 |
| PMCA guard / enforcer (patrol) | `npc_pmca_guard` or `guard_body` static | idle, patrol (flip) | **Tier 1** | Ch1–8 patrol routes |
| Archive clerk | `npc_archive_clerk` | idle, talk | Tier 2 | Ch4 |
| Quiet Choir contact | `npc_choir_contact` | idle, beckon | Tier 2 | Ch7 |
| Helix maintenance tech | `npc_helix_tech` | idle, talk | Tier 2 | Ch5–6 |
| Frightened citizen | `npc_civilian_worried` | idle, talk | Tier 3 | Ch3+ crowd scenes |
| PMCA audit officer | `npc_audit_officer` | idle, talk | Tier 3 | Ch8 |

### D. Security / hazard sprites

| Asset | Status | Notes |
|-------|--------|-------|
| Directional drone trio | ✅ Final | `drone_side_left/right`, `drone_down` |
| Drone stun state | ✅ Code | Teal tint + faded cone |
| Patrol guard sprite | ❌ Missing | Procedural humanoid in `buildGuardSprite` |
| Camera housing sprite | ❌ Missing | Procedural in `SecurityCameraNode` |
| Scanner gate (Ch4) | ❌ Missing art | Ch4 mechanic code-driven; needs beam/gate sprite |
| Access barrier / bollard | ❌ Missing | `FieldEnvironmentDecor.barrier` procedural |
| Enforcer robot (boundary) | ❌ Missing | `enforcementRobot()` procedural |
| Alarm beacon | ❌ Missing | Blinking rects on buildings |

### E. Puzzle / hacking visuals

| Element | Status | Notes |
|---------|--------|-------|
| Hack port world sprite | Placeholder | `networkAccessNode()` |
| PDA hack UI panels | ✅ UI code | `PDAHackPanel` — no raster dependency |
| Frequency tuner UI | ✅ UI code | Procedural widgets |
| Credential injection UI | ✅ UI code | Procedural |
| Node router icon | ❌ Missing | Optional UI icon in hack panel |
| Scan pulse | ✅ Mara atlas | `mara_scan_observe_*` |
| Data transfer particles | ❌ Missing | Optional Tier 3 polish for hack success |
| Security bypass panel | ✅ UI + placeholder prop | |

---

## Task 3 — Priority tiers

### Tier 1 — Before Chapters 2–3 polish (remove visible placeholders)

1. `bg_housing_mid` + `bg_housing_near` — Ch3 JSON already references; highest-impact missing backgrounds  
2. `pmca_terminal_kiosk_v1` — most repeated interactable across Ch1–3  
3. `npc_maintenance_worker` atlas (idle + talk) — Ch2 `maint_worker_12`  
4. `npc_resident_informant` atlas (idle + talk) — Ch3 `resident_305`  
5. `npc_pmca_guard` / `guard_body` — all `security_guard` patrols (Ch1–3)  
6. `security_camera_wall_v1` — Ch1–3 camera placements  
7. `pda_hack_port_v1` — security override interactables (Ch1–3)  
8. `maintenance_locker_v1` + `prop_data_cartridge_v1` — Ch2 cabinet + cartridge beat  
9. `door_sealed_archive_v1` + `access_keypad_v1` — checkpoint interior puzzle readability  
10. `enforcer_robot_v1` — field boundary blockers (all three levels)  
11. `pmca_notice_board_v1` — Ch2–3 information nodes  
12. `ground_housing_corridor_v1` — optional but strongly improves Ch3 floor read  

### Tier 2 — Before Chapters 4–8 production

| Asset group | Chapters |
|-------------|----------|
| `bg_annex_mid` (+ optional near) | Ch4 Ghost Audit |
| `bg_meridian_mid` | Ch5 atmosphere |
| `bg_train_mid` (+ near, `ground_train_platform_v1`) | Ch6 Black Mail Train |
| `bg_undercity_mid` (+ near) | Ch7 Choir Beneath |
| `bg_central_archive_mid` (+ near) | Ch8 infiltration |
| `npc_archive_clerk`, `npc_choir_contact`, `npc_helix_tech` | Ch4–7 |
| `scanner_gate_v1`, `archive_cabinet_v1` | Ch4 records annex |
| `building_checkpoint_gate_v1`, `building_relay_depot_v1` | Reusable exteriors |
| `sign_pmca_sector_v1`, `sign_helix_meridian_v1`, `graffiti_quiet_choir_v1` | Faction dressing |
| `ground_archive_tile_v1` | Ch4/8 floors |

### Tier 3 — Nice-to-have polish (post all chapters playable)

- `platform_gantry_v1` wiring (only if elevated walkways return to design)  
- `icon_pickup_data`, `icon_cartridge` world icons  
- `prop_evidence_marker_v1`  
- Data transfer particle sprites for hack success  
- `splash_ch1`–`splash_ch8` chapter select thumbnails  
- Variation drones (heavy/industrial variant)  
- Animated warning beacons (2-frame)  
- Interior wallpaper textures for relay/checkpoint rooms  

---

## Task 4 — Implementation readiness (Tier 1 + key Tier 2)

| Filename | Folder | Dimensions | Animated? | Code integration | Placeholder replaced | Code support |
|----------|--------|------------|-----------|------------------|---------------------|--------------|
| `bg_housing_mid.png` | `Assets.xcassets/bg_housing_mid.imageset/` | 6144×800 strip | Static | `PlatformScene.buildBackgroundLayer` | Procedural skyline | ✅ `imageName` in JSON |
| `bg_housing_near.png` | `Assets.xcassets/bg_housing_near.imageset/` | 6144×800, top 50% alpha | Static | Same | Procedural near | ✅ JSON reference |
| `pmca_terminal_kiosk_v1.png` | `assets/assets/props/` → xcassets | 68×96 @2x | Static | `FieldInvestigationVisuals.pmcaFieldTerminal()` | Procedural kiosk | ✅ Factory exists — swap texture |
| `security_camera_wall_v1.png` | `assets/assets/props/` | 36×72 @2x | Static | `SecurityCameraNode.buildVisual` | Grey box housing | ✅ Node exists |
| `npc_pmca_guard.png` or atlas | `assets/assets/sprites/guard/` | 48×110 @2x | Static or 2-frame idle | `DroneEnemyNode.buildGuardSprite` | Procedural guard | ✅ `isGuard` path |
| `npc_maintenance_worker_*.png` | `assets/assets/sprites/npc_maint/` | 40×100 @2x | 7–10 frames idle/talk | New node or generalise `WorkerKHaasNode` pattern | `buildPlaceholderNPC` | ✅ Atlas pattern proven (Haas) |
| `npc_resident_*.png` | `assets/assets/sprites/npc_resident/` | 36×90 @2x | 7–10 frames | Same | Placeholder NPC | ✅ Pattern proven |
| `pda_hack_port_v1.png` | `assets/assets/props/` | 48×80 @2x | Static | `networkAccessNode()` | Procedural port | ✅ Factory exists |
| `maintenance_locker_v1.png` | `assets/assets/props/` | 52×128 @2x | Static | `maintenanceCabinet()` | Procedural locker | ✅ |
| `prop_data_cartridge_v1.png` | `assets/assets/props/` | 32×32 @2x | Static | `dataCacheUnit()` | Procedural crate | ✅ |
| `door_sealed_archive_v1.png` | `assets/assets/props/` | 88×152 @2x | Static | `PlatformInteriorVisuals.fortifiedDoor` | Procedural door | ✅ |
| `access_keypad_v1.png` | `assets/assets/props/` | 28×36 @2x | Static | Door backdrop child | Procedural keypad | ✅ |
| `enforcer_robot_v1.png` | `assets/assets/sprites/` | 72×120 @2x | Static | `FieldInvestigationVisuals.enforcementRobot` | Procedural robot | ✅ |
| `pmca_notice_board_v1.png` | `assets/assets/props/` | 76×88 @2x | Static | `publicNoticeBoard()` | Procedural board | ✅ |
| `ground_housing_corridor_v1.png` | `Assets.xcassets/` | 512×80 tileable | Static | `buildFloor` — needs new `imageName` per level or theme flag | Industrial road | ⚠️ Needs small level JSON or floor profile extension |
| `bg_train_mid.png` | `Assets.xcassets/bg_train_mid.imageset/` | 6144×800 | Static | Future `level_ch6.json` | `bg_facility_mid` | ⚠️ Level not authored |
| `bg_undercity_mid.png` | `Assets.xcassets/bg_undercity_mid.imageset/` | 6144×800 | Static | Future `level_ch7.json` | Facility mid | ⚠️ Level not authored |
| `bg_central_archive_mid.png` | `Assets.xcassets/bg_central_archive_mid.imageset/` | 6144×800 | Static | Future Ch8 infiltration | Facility mid | ⚠️ Level not authored |

**Import rules (all field sprites):** PNG + transparency · nearest-neighbour filtering for props/sprites · no texture smoothing · match `docs/ArtStyleGuide.md` posterize pipeline.

---

## Assets present but not implemented

| Asset | Catalog | Code support | Why unused | Safe integration? |
|-------|---------|--------------|------------|-------------------|
| `platform_gantry_v1` | ✅ PNG in xcassets | ✅ `platformAssetProfile` in `PlatformScene` | All `platformNodes` arrays empty; investigation pivot deprioritises walkways | Only if level JSON adds `platformNodes` — **not recommended now** |
| `pmca_drone_v1` | ✅ | ✅ Fallback in `DroneEnemyNode` | Superseded by directional `drone_side_*` + `drone_down` | Keep as fallback only |
| `mara_silhouette` | ✅ | ✅ Atlas fallback | Mara.atlas loads successfully in sim | Keep as fallback only |
| Source `BG_facility_*_v1.png` | Source only | — | Duplicate naming; catalog uses `bg_facility_*` | Do not import duplicate |
| `assets/assets/platforms/platform_gantry_v1.png` | Source only | Catalog copy exists | See gantry above | — |

**No code changes made in this audit pass** — gantry wiring would be gameplay/layout scope; directional drones already integrated.

---

## Chapter coverage matrix

| Chapter | Level JSON | Field assets final | Field assets placeholder | Critical missing |
|---------|------------|--------------------|--------------------------|------------------|
| **Ch1** | ✅ + 2 interiors | Mara, Haas, drones, parallax trio, road | Buildings, terminals, cameras, guard, decor, interiors | Guard sprite, terminal sprite, camera sprite |
| **Ch2** | ✅ | Mara, drones, parallax, road | NPC maint worker, all props, guard, camera | `npc_maintenance_worker`, terminal, locker, cartridge |
| **Ch3** | ✅ | Mara, drones, `bg_city_far`, road | Housing parallax (**missing**), resident NPC, decor facades | **`bg_housing_mid/near`**, resident sprite |
| **Ch4** | ❌ | Defaults (facility parallax) | All interactables TBD | `bg_annex_mid`, archive props, scanner art |
| **Ch5** | ❌ (desk only) | — | — | `bg_meridian_mid` (desk/atmo); minimal field |
| **Ch6** | ❌ | — | — | `bg_train_mid`, train props, floor |
| **Ch7** | ❌ | — | — | `bg_undercity_mid`, Choir contact NPC |
| **Ch8** | ❌ (desk climax) | — | — | `bg_central_archive_mid`, infiltration props |

---

## Production checklist

### Inventory complete ✅
- [x] Scan `Assets.xcassets`, `assets/assets/`, atlases, level JSON, platform code

### Tier 1 — generate & import
- [ ] `bg_housing_mid.png` → `bg_housing_mid.imageset`
- [ ] `bg_housing_near.png` → `bg_housing_near.imageset`
- [ ] `pmca_terminal_kiosk_v1.png`
- [ ] `security_camera_wall_v1.png`
- [ ] `npc_pmca_guard` sprite (or atlas)
- [ ] `npc_maintenance_worker` atlas (idle, talk)
- [ ] `npc_resident_informant` atlas (idle, talk)
- [ ] `pda_hack_port_v1.png`
- [ ] `maintenance_locker_v1.png`
- [ ] `prop_data_cartridge_v1.png`
- [ ] `door_sealed_archive_v1.png` + `access_keypad_v1.png`
- [ ] `enforcer_robot_v1.png`
- [ ] `pmca_notice_board_v1.png`
- [ ] (Optional) `ground_housing_corridor_v1.png` + floor profile in code

### Tier 1 — wire in code (after art lands)
- [ ] Swap textures in `FieldInvestigationVisuals` factories
- [ ] Swap guard texture in `DroneEnemyNode.buildGuardSprite`
- [ ] Swap camera housing in `SecurityCameraNode`
- [ ] Add `WorkerMaintenanceNode` / `ResidentNPCNode` following `WorkerKHaasNode` pattern
- [ ] Verify Ch2–3 playthrough — no missing texture warnings

### Tier 2 — per chapter (before respective ship)
- [ ] Ch4: `bg_annex_mid`, scanner gate, archive clerk NPC
- [ ] Ch6: `bg_train_mid`, train floor, carriage door props
- [ ] Ch7: `bg_undercity_mid`, Choir contact NPC, graffiti mark
- [ ] Ch8: `bg_central_archive_mid`, audit officer NPC

### Tier 3 — polish queue
- [ ] Chapter splash `splash_ch1`–`splash_ch8`
- [ ] Pickup icons `icon_cartridge`, `icon_pickup_data`
- [ ] Evaluate `platform_gantry_v1` against final design

---

## References

| Document | Path |
|----------|------|
| This audit | `docs/design/Platform_Field_Asset_Completion_Audit.md` |
| Phase 0.6 production specs | `docs/Phase0.6_GlobalAssetProductionPack.md` |
| Ch1–3 art brief | `ART_BRIEF_CH1_CH3.md` |
| Level data | `DeadLetterOffice/Data/Levels/level_ch*.json` |
| Encounter modules | `DeadLetterOffice/Models/PlatformEncounterModel.swift` |

---

*Audit produced 2026-06-07 from filesystem scan + code review. No assets generated. No gameplay changes.*
