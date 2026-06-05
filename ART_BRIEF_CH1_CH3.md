# Dead Letter Office — Art Brief: Ch1–Ch3 Platform Assets

All assets are PNG with transparency unless marked otherwise.
Tone: brutalist bureaucratic dystopia, cyberpunk-adjacent, muted palette.
Primary colours: near-black background (#080D14), teal accent (#00B5C9), amber text (#FFB533), danger red (#D9260A).

---

## PLAYER CHARACTER

### mara_silhouette
- **File**: `mara_silhouette.png`
- **Size**: 56×120 px (2× target 28×60 pt)
- **Transparent**: yes
- **Purpose**: MaraPlayerNode body — auto-loaded, falls back to procedural if missing
- **Notes**: Female silhouette in long dark coat. Teal trim on shoulders. Hood or cropped hair. Facing right by default (engine mirrors for left movement). Proportions: legs ~40%, torso ~40%, head ~20%. Keep form readable at 28pt wide on device.

### mara_full_portrait (desk scene / cutscene use)
- **File**: `portrait_mara.png` (already in xcassets)
- **Size**: 200×280 px
- **Transparent**: yes
- **Purpose**: Dialogue portrait for Mara. High contrast amber/dark palette. Bureaucratic ID-photo framing.

---

## NPCs

### npc_haas (K. HAAS — Sorting Facility worker)
- **File**: `npc_haas.png`
- **Size**: 40×100 px
- **Transparent**: yes
- **Purpose**: Ch1 NPC. Facility worker uniform. Hunched posture, looking over shoulder. Male. Drab grey-green jumpsuit with PMCA shoulder badge.

### npc_resident (Housing Block resident)
- **File**: `npc_resident.png`
- **Size**: 36×90 px
- **Transparent**: yes
- **Purpose**: Ch3 NPC (Resident Unit 305). Civilian in worn residential clothes. Slight, standing near a wall. Neutral/exhausted posture.

### npc_maintenance (SVC-19-4A — Maintenance worker)
- **File**: `npc_maintenance.png`
- **Size**: 40×100 px
- **Transparent**: yes
- **Purpose**: Ch2 NPC. Maintenance uniform — darker, utility belt, PMCA maintenance band on arm. Amber override patch visible.

### npc_pmca_clerk (Generic PMCA desk clerk)
- **File**: `npc_pmca_clerk.png`
- **Size**: 40×100 px
- **Transparent**: yes
- **Purpose**: Optional background NPC. Standard PMCA uniform (charcoal with amber insignia). Upright, clipboard in hand.

---

## HAZARDS / ENEMIES

### drone_body (Security surveillance drone)
- **File**: `drone_body.png`
- **Size**: 72×36 px
- **Transparent**: yes
- **Purpose**: DroneEnemyNode body when `isGuard = false`. Horizontal ovoid silhouette. Two teal running lights on underside. Scan cone rendered separately in engine (amber/yellow, 18% opacity).
- **Notes**: Must read clearly against dark background. Slight mechanical sheen. No text or labels.

### guard_body (Security guard silhouette)
- **File**: `guard_body.png`
- **Size**: 48×110 px
- **Transparent**: yes
- **Purpose**: DroneEnemyNode body when `isGuard = true`. Human silhouette in heavy coat. Red armband visible. Side-facing (facing right, engine mirrors). Thick-soled boots, visor helmet or balaclava.
- **Notes**: Distinct from Mara — bulkier, straighter posture, armband is key read.

---

## ENVIRONMENT — INTERACTABLES

### icon_terminal
- **File**: `icon_terminal.png`
- **Size**: 48×48 px
- **Transparent**: yes
- **Purpose**: Terminal interactable marker in world. CRT screen with amber text glow. Mounted on wall bracket. Visible at small size.

### icon_door
- **File**: `icon_door.png`
- **Size**: 32×80 px
- **Transparent**: yes
- **Purpose**: Door/barrier interactable visual. Vertical slab with amber keypad panel on right side. Teal edge strip when open, red when locked.

### icon_cartridge
- **File**: `icon_cartridge.png`
- **Size**: 32×32 px
- **Transparent**: yes
- **Purpose**: Data cartridge collectible. Small rectangular chip with teal circuit trace. Floats and bobs in engine.

### icon_text_sign
- **File**: Not required — rendered as text in engine.

---

## ENVIRONMENT — SURFACES

### platform_tile
- **File**: `platform_tile.png`
- **Size**: 32×20 px, tileable horizontally
- **Transparent**: no — dark blue-grey surface (#1B2638)
- **Purpose**: Platform surface tile. Should have a subtle metallic texture or panel lines. Teal top edge line (2px) is rendered in engine and overlaid — asset only needs the body.

### ground_tile
- **File**: `ground_tile.png`
- **Size**: 32×40 px, tileable horizontally
- **Transparent**: no — same colour as platform_tile but heavier/darker
- **Purpose**: Floor tile used for the main ground surface. Hazard stripe pattern optional at base edge (amber/black diagonal, 30% opacity).

---

## BACKGROUNDS

### bg_facility_far (Ch1 + Ch2 far layer)
- **File**: `bg_facility_far.png`
- **Size**: 3000×500 px (wider than any single level)
- **Transparent**: no — background layer, darkest
- **Purpose**: Distant city silhouette behind Ch1/Ch2. Near-black skyline of brutalist towers. A few lit amber windows. Slight rain-streak vertical lines (subtle).
- **Scroll factor**: 0.1 (barely moves — used as atmospheric depth)

### bg_facility_mid (Ch1 + Ch2 mid layer)
- **File**: `bg_facility_mid.png`
- **Size**: 3000×500 px
- **Transparent**: yes (top portion) — composites over far
- **Purpose**: Facility interior mid-layer. Structural columns, pipe runs, conveyor belt silhouettes. Amber safety lighting pools. Horizontal bands suggesting industrial ceiling.
- **Scroll factor**: 0.4

### bg_facility_near (Ch1 + Ch2 near layer)
- **File**: `bg_facility_near.png`
- **Size**: 3000×500 px
- **Transparent**: yes — large cutouts for the play area
- **Purpose**: Foreground dressing. Wall panels, cable trays, emergency signage frames (no text). Creates depth in front of platforms.
- **Scroll factor**: 0.7

### bg_housing_mid (Ch3 mid layer)
- **File**: `bg_housing_mid.png`
- **Size**: 5500×500 px
- **Transparent**: yes
- **Purpose**: Housing block interior mid-layer. Corridors, numbered unit doors (small), a bulletin board silhouette. Muted residential palette — slightly warmer than facility. Fluorescent strip lighting (cold white glow at ceiling).
- **Scroll factor**: 0.4

### bg_housing_near (Ch3 near layer)
- **File**: `bg_housing_near.png`
- **Size**: 5500×500 px
- **Transparent**: yes
- **Purpose**: Near foreground of housing block. Sealed unit notices visible as shapes (no readable text — readability comes from in-game text nodes). Open duct work upper right.
- **Scroll factor**: 0.7

---

## GENERATION PROMPT NOTES (Midjourney / Stable Diffusion reference)

**Style reference**: "brutalist bureaucratic dystopia, cyberpunk game asset, silhouette sprite, dark teal and amber palette, strong contrast, flat graphic style, no gradients, clean edges, 2D side-scroller"

**Avoid**: photorealism, ornate detail at small sizes, bright white, soft gradients, symmetrical compositions for characters (add slight lean/pose), any text or logos on environmental assets.

**Key differentiators from generic cyberpunk**: The PMCA aesthetic is deliberately mundane-sinister — office-like, bureaucratic, not flashy. Hazards look like security infrastructure, not science fiction weapons. Characters look tired, not heroic.
