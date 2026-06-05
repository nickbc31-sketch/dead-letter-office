# Dead Letter Office — Art Brief: Scene Backgrounds
## bg_desk_office / bg_main_menu

**Document type:** Production art brief — visual asset direction only
**Date:** 2026-06-02
**Authority:** ArtStyleGuide.md v1.0, AssetProductionPlan.md v4.0, CANON.md, DLOColors.swift
**Applies to:** bg_desk_office (BG-001), bg_main_menu (BG-002)

---

## Style Mandate (read before anything else)

Both backgrounds are 1990s DOS-era PC game environments. The aesthetic target is *Flashback: The Quest for Identity* (1992) crossed with *Papers, Please* (2013). Every element must be:

- **Flat-shaded** — discrete colour bands, zero smooth gradients between light and shadow
- **Hard-edged** — the terminator between lit and unlit surfaces is a line, not a blur
- **Dark-dominant** — average luminance below 30% (verify with histogram before export)
- **Sparse** — the game's visual authority comes from what is not shown, not from detail
- **Matte** — no specular highlights, no glossy surfaces, no ambient occlusion darkening in corners

**Single rejection rule:** If the output could appear in a 2023 mobile game, it is wrong. Discard it.

---

## Shared Colour Palette

Both backgrounds must use only these values as dominant colours. Intermediate shadow tones within a hue family are permitted; new hues are not.

| Role | Hex | Use in environment |
|---|---|---|
| Primary void | `#070D14` | Dominant background fill, open air, empty space |
| Terminal dark | `#0D1420` | Secondary surfaces — walls, deep shadow |
| Slate | `#182030` | Raised surfaces, distant architectural forms |
| Steel blue | `#405873` | UI-adjacent surfaces, near shadow planes |
| Dusty khaki | `#736B59` | Aged material mid-tone, old wood |
| PMCA teal | `#00B5C9` | Accent light source — cold edge highlights, screen glow |
| Terminal amber | `#FFB533` | Warm light source — desk lamp, CRT phosphor, filament glow |
| Aged paper | `#DED7BD` | Document surfaces only — do not use for architecture |
| Near-black | `#050810` | Deepest shadow, silhouette fill |

**Forbidden in these assets:** Purple, magenta, neon green, bright orange, pure white (#FFFFFF), pure red (#FF0000). Amber and teal must remain dim — they are accent glows, not bright lights.

**Luminance cap on highlights:** The brightest visible element in either background must not exceed 80% luminance. Amber is warm but never blazing.

---

---

# ASSET 1: bg_desk_office

**Asset ID:** BG-001
**Filename:** `bg_desk_office@2x.png`
**Destination:** `Assets.xcassets/Backgrounds/bg_desk_office.imageset/`

---

## Narrative Purpose

This is the place where Mara Venn processes the dead. She sits at this desk for every case in every chapter across the game's full three-hour runtime. The desk is the game.

It is not a home. It is not a comfortable workspace. It is an instrument — the place where institutional authority becomes a physical action (a stamp). The CRT terminal is the interface to a system that decides who exists. The lamp is the only concession to human needs.

The desk has been used by other clerks before Mara. It will be used by clerks after her. It shows this. The wear is not romantic decay — it is the mundane erosion of sustained bureaucratic labour.

The background must create the feeling of being watched. The filing cabinets behind the desk contain the dead. There is no window. There is no exit visible. There is only the desk, the lamp, the terminal, and the work.

---

## Emotional Tone

**Oppressive calm.** The room is not threatening in an obvious way. It is simply a room built for a single purpose, stripped of everything that purpose does not require. The absence of comfort is the threat.

Secondary tone: **weight**. The filing cabinets are full. The inbox tray has paper in it. The CRT is already on. The shift has already started. The player arrived after the institution did.

What the player should feel when they see this background: *this is serious work, and it has been going on without me.*

---

## Required Visual Elements

### Primary (must appear)
1. **Desk surface** — occupying the lower 40–50% of the composition. Dark wood or laminate, worn smooth at the working area. The surface should show age without romanticism: a few scuff marks, the faint rectangle impression of a previous object, slight discolouration at the front edge from years of sleeve contact. Not cluttered.

2. **CRT terminal** — positioned right-of-centre or centre-right on the desk surface. Amber phosphor glow from the screen. The screen should emit enough light to cast a warm pool on the desk surface below it. The screen itself should not show content — it is lit but blank or shows a single abstract amber line. The body of the terminal is dark grey, angular, 1980s industrial.

3. **Desk lamp** — positioned left-of-centre or far left. A single incandescent or amber industrial desk lamp, casting a sharp-edged cone of warm light on the desk surface. The cone should be visible as a brighter area on the desk, with a hard edge between lit and unlit. The lamp is the only source of warm light if the CRT is excluded.

4. **Filing cabinets** — occupying the background wall, receding behind and above the desk. Dark metal, identical units. Multiple drawers, some with small amber-lit label holders. The cabinets should feel numerous — more than two, not perfectly aligned, filling the wall with repetition. The repetition is the point. Each cabinet contains more cases.

5. **Desk blotter or work surface mat** — a worn leather or vinyl rectangle under the terminal and lamp. Dark green or dark brown. Shows age.

6. **Inbox/outbox tray** — wire mesh or metal, positioned on the desk. Should contain a visible suggestion of paper (light-coloured rectangle shapes, not detailed documents). Does not need to be prominent.

### Secondary (include where composition allows)
7. **Electrical cable** or cord from the terminal — trailing toward the back of the desk
8. **Dark recessed wall** — the wall behind the filing cabinets should be barely visible, very dark, suggesting the room continues behind the cabinets
9. **Ceiling shadow** — the upper portion of the image should be very dark, suggesting a low institutional ceiling with no overhead lighting

### Excluded (must not appear)
- Windows or exterior views of any kind
- Any person, silhouette, or suggestion of a person
- Artwork, plants, personal objects
- Obvious brand names, visible text, signage
- Modern office furniture or aesthetics
- Computer mice, external keyboards (the terminal has its own integrated keyboard, not visible)
- Papers with readable content

---

## Required Lore Elements

The desk exists in PMCA headquarters, Administrative Core district, Veyr, year 2147. The PMCA was founded in 2121. This desk has been in institutional service for decades.

Key lore atmosphere details:
- **No natural light** — the PMCA archive is deep in the building. The lamp and terminal are the only light sources because there are no windows.
- **PMCA institutional aesthetic** — the furniture is standardised, grey, functional. Not military but adjacent. The stamp of institutional indifference is on every surface.
- **The work never ends** — the inbox tray has paper in it. This is not the start of Mara's shift; the previous clerk left work for her.
- **The filing cabinets are full** — by implication, this system has been running for 26 years. The cabinets represent the accumulated dead of a city.

---

## Camera Angle

**Slight overhead, three-quarter view.** The camera looks down at approximately 15–20 degrees from horizontal. This angle:
- Makes the desk surface visible as a working plane (not just an edge)
- Allows the filing cabinets to recede naturally into depth behind the desk
- Creates a sense that the player is sitting at the desk, looking at their workspace
- Avoids a top-down plan view (which would eliminate depth) or a straight horizontal view (which would reduce the desk to a line)

The perspective lines should recede toward a vanishing point in the upper-centre of the frame, creating a slight depth illusion without any 3D rendering.

---

## Composition Notes

The composition serves a critical functional purpose: **the UI overlays most of this image**. The document panel covers approximately the left 59% of the screen. The stamp/message panel covers approximately the right 35%. The status bar covers the top 28pt.

This means the background is most visible in:
- **The narrow vertical strip between the document panel and stamp panel** (around 6% of width, centred at 65% from left)
- **The bottom edge** — below the document panel baseline
- **Thin fragments visible through UI gaps**

**Design implication:** The background should not rely on a single focal point. It should work as an atmospheric environment that reads correctly even when 90% of it is covered. The desk surface visible at the bottom, the filing cabinet tops visible above the document panel, and the narrow strip in between should all feel like pieces of the same coherent room.

**Specific zone guidance:**
- **Upper half (approximately):** Filing cabinets and dark wall — this is visible above the document panel when the game is running
- **Lower 30%:** Desk surface with lamp and CRT — most visible in the gaps and bottom edge
- **Right ~10% (visible past the stamp panel):** Dark wall or the side of the nearest filing cabinet
- **Centre strip:** The lamp cone and CRT glow should be positioned so they're at least partially visible through the narrow centre gap

**Left third darkest.** The document panel has a light aged-paper background and the game renders amber text. The background behind it should be its darkest there — the filing cabinets rather than any lit surface.

**No focal point centre.** Resist the instinct to place the CRT dead-centre. Off-centre placement (right-of-centre) reads better through the UI strip.

---

## UI-Safe Areas

The following areas of the canvas are COVERED by UI elements during gameplay and will not be directly seen by the player. Design can be coarser here, but continuity of environment is still needed in case the background is visible on different device aspect ratios:

| Region | Covered by | Priority |
|---|---|---|
| Left 59% of canvas (middle) | Document panel (aged paper) | Low — design coarsely |
| Right 30% of canvas (middle) | Stamp buttons and message area | Medium — partially transparent |
| Top 6% of canvas | Status bar (solid black) | Low |

The following areas ARE visible and must be fully detailed and polished:

| Region | Visibility | Priority |
|---|---|---|
| Upper portion (above document panel top) | Filing cabinets, wall — HIGH visibility | High |
| Lower portion (below document baseline) | Desk surface, base elements — HIGH visibility | High |
| Centre-right strip (~65–70% from left) | Gap between panels — narrow but unobstructed | High |
| Far right edge (past stamp panel) | Wall, side of cabinet | Medium |

---

## Resolution Requirements

| Stage | Canvas | Dimensions | Notes |
|---|---|---|---|
| ComfyUI generation | 1280×592 px | 2.16:1 (matches game aspect ratio ~2.17:1) | Multiples of 64; SDXL-compatible |
| DiffusionBee generation | 1344×768 px | 1.75:1 (per AssetProductionPlan) | Stretch tolerance applies |
| Post-processing target | — | Posterize lvl 8, palette correct, contrast boost | Average luminance < 30% |
| Final export | 2668×1500 px or 2560×1184 px | — | Upscale via Lanczos or RealESRGAN |
| Xcode import | `bg_desk_office@2x.png` | Match export dimensions | 2x slot in imageset |

**Aspect ratio note:** The game renders at approximately 956×440pt (ratio 2.17:1). The standard AssetProductionPlan canvas (1344×768, ratio 1.75:1) will be horizontally stretched approximately 24% when the game scales it to scene.size. For ComfyUI, use 1280×592 to match the game ratio and avoid distortion.

---

## ComfyUI Generation Prompt

### Positive Prompt
```
PMCA government clerk desk environment, 1990s DOS PC game background art, Flashback 1992 game aesthetic, Papers Please art style, bureaucratic dystopia, institutional interior

dark worn wooden desk surface occupying lower half of frame, three-quarter overhead view 15 degrees below horizontal, slight overhead perspective, heavy dark institutional CRT terminal with amber phosphor glow right of center on desk surface, single amber incandescent desk lamp left of center casting sharp-edged cone of warm light on desk, worn dark green leather desk blotter, wire mesh inbox tray with paper stacks

floor-to-ceiling dark metal filing cabinets covering background wall, receding into depth, rows of identical drawer units, small amber-lit label holders, institutional repetition, no people visible

flat shading with hard shadow edges, discrete colour bands no gradients, limited colour palette navy and amber and teal, teal cold edge highlights, amber warm lamp glow, near-black shadows reaching #050810, dark dominant 70 percent of image area, matte surfaces no specular highlights no ambient occlusion

limited 12 colour palette, posterised graphic quality, dark navy void #070D14, steel blue surfaces #405873, terminal amber accent #FFB533, PMCA teal accent #00B5C9, deep shadow near-black, aged dark wood tone

no photorealism, no smooth gradients, no 3D rendering, hard graphic style, Another World 1991 environment aesthetic, dark oppressive institutional quiet
```

### Negative Prompt
```
photorealistic, hyperrealistic, subsurface scattering, ambient occlusion, specular highlights, smooth gradients, soft lighting, cinematic lighting, 3d render, vray render, octane render, blender, studio lighting

windows, daylight, sunlight, exterior view, natural light, sky visible, bright room

person, human, silhouette of person, hands, figure

modern office furniture, ergonomic chair, laptop, smartphone, flat screen monitor, wireless keyboard, mouse pad, potted plant, artwork on wall, personal photographs, coffee mug, modern aesthetics

photorealistic wood grain texture, realistic metal sheen, fabric weave detail, stone texture, realistic material rendering

bright colours, saturated colours, neon colours, purple, magenta, bright orange, pure white, cheerful palette, warm cosy atmosphere

anime style, cartoon style, cell shading, comic book style, western animation, watercolour, oil painting, impressionistic

text visible, logos, signage, brand names, readable labels

glossy surfaces, wet surfaces, plastic sheen, chrome reflection
```

---

## Generation Settings

| Setting | Value | Rationale |
|---|---|---|
| Model | DreamShaper XL Turbo | Stylised output; resists photorealism at low CFG |
| Canvas | 1280×592 px (ComfyUI) or 1344×768 px (DiffusionBee) | See resolution notes above |
| Steps | 10–12 | Enough for environment; turbo model needs fewer steps |
| CFG / Guidance | 2.5–3.0 | Lower = more graphic/stylised, less photographic |
| Sampler | Euler or DPM++ 2M Karras | Consistent, predictable for environments |
| Seed policy | Random for first 6 batches; lock on best composition | Environments need iteration |
| Batch count | 6–8 | Turbo variance is high; review multiple options |

---

## Post-Processing Sequence (Pixelmator)

1. Export PNG from ComfyUI
2. **Posterize** — Effects → Stylize → Posterize, Level **8** — eliminates smooth gradients
3. **Palette correction** — Hue/Saturation:
   - Desaturate any colour not in the game palette (especially reds, greens, cyans that don't match #00B5C9)
   - Push blues/navies toward `#070D14`
   - Push warm tones toward `#FFB533` amber family
4. **Contrast boost** — Levels: push blacks to `#050810`, pull highlights down to max 80% luminance
5. **Histogram check** — average luminance must be below 30%. If over 30%, darken with a Curves adjustment pulling the midpoints down
6. **Silhouette test** — flatten to black on white. The desk, lamp, terminal, and cabinets must all read as distinct shapes
7. **Upscale** — Lanczos to 2668×1500 px (or 2560×1184 for 2.17:1 ratio)
8. **Final check** — confirm no photorealistic elements survived. Look for gradient skin tones (wrong model), smooth gradient shadows (increase posterize level), or oversaturated accent colours (hue-correct)

---

## Approval Criteria

The background is approved when:
- [ ] The environment is clearly a bureaucratic institutional desk workspace
- [ ] Average luminance is below 30%
- [ ] No smooth gradients — all shading is hard-edged colour bands
- [ ] Amber lamp and teal CRT glow are the only visible light sources
- [ ] Filing cabinets are visible in the background as repetitive dark forms
- [ ] CRT terminal shows amber phosphor glow on dark screen
- [ ] No photorealistic materials are visible
- [ ] Maximum colour count: 16 distinct colours
- [ ] The image reads legibly as a coherent room even when 80% is covered by a dark overlay
- [ ] The composition works when the left 60% and right 35% are obscured by the game UI — the visible strips (top, bottom, centre gap) still suggest a room

---

---

# ASSET 2: bg_main_menu

**Asset ID:** BG-002
**Filename:** `bg_main_menu@2x.png`
**Destination:** `Assets.xcassets/Backgrounds/bg_main_menu.imageset/`

---

## Narrative Purpose

This is the first image the player sees. It is not gameplay — it is the world before gameplay begins. The player is looking at Veyr before they become Mara.

The image is the PMCA Central Archive at night. This is the institution the player is about to work for. The filing cabinets extend to the vanishing point. The single empty desk in the foreground waits. Through a tall narrow window in the far background — the only one in the building — the city of Veyr glows teal and cold in the rain.

The image answers one question before the player asks it: *what kind of world is this?*

The answer: a world in which death is administered from a large dark room full of identical filing cabinets, where one lamp illuminates one empty desk, and outside the window the city continues regardless.

The empty desk is the most important element. It is where Mara will sit. It is currently unoccupied. Someone just finished a shift, or hasn't arrived yet.

---

## Emotional Tone

**Sublime institutional dread.** Not frightening — important. The scale of the archive dwarfs the human-scale desk in the foreground. The cabinets stretch to infinity. The PMCA has been running for 26 years. This room has been here longer than Mara has worked in it.

Secondary tone: **loneliness**. The room is enormous. The lamp illuminates very little of it. The city visible through the single window is teal and distant. The desk is empty.

Tertiary (very subtle): **invitation**. The empty desk, the lit lamp, the city visible in the distance. Something is waiting. The shift is about to begin.

What the player should feel: *this game is serious, and it takes place in a world larger than I can see.*

---

## Required Visual Elements

### Primary (must appear)
1. **Vast archive interior** — the room must feel large. Rows of identical dark metal filing cabinets receding to a vanishing point in the upper centre of the frame. The cabinets should be numerous enough that they establish repetition as a concept, not just as decoration. The vanishing point should be visible — the lines of the cabinet tops and bases should converge clearly.

2. **Single empty desk** — foreground, slightly left of centre. A plain institutional desk: dark surface, worn, nothing personal on it. No chair visible if possible (the chair is absent — the clerk has not arrived). A single lamp on the desk, lit. A terminal or CRT may be on the desk, powered off or showing only a cursor. The desk is the focal point of the foreground.

3. **Single amber desk lamp** — on the foreground desk. Lit. Warm amber cone of light falling on the desk surface. This is the warmest element in the image. Hard-edged cone, not a soft glow.

4. **Tall narrow window** — background, far distance, positioned somewhere between centre and right. It should be small relative to the frame — the window is far away, down the corridor of filing cabinets. Through the window: the city of Veyr at night. The city should be visible as dark shapes with teal-lit upper surfaces and sparse amber pinpoints of light. The window does not let in light; it is a portal of cold observation, not warmth.

5. **Filing cabinet corridor** — the dominant mid-ground element. Dark metal cabinets on both sides of an implied corridor, receding. Each cabinet row is identical. The tops of the cabinets should be barely visible at the edge of the lamp's cone. The bases disappear into shadow.

### Secondary (include where composition allows)
6. **Very faint ceiling grid** — institutional suspended ceiling above, barely visible in the darkness. Receding lines suggesting scale. Should not be prominent.
7. **Dark floor** — reflecting nothing. The floor is dark laminate or concrete, with the faintest amber reflection from the foreground desk lamp. Not a mirror; a suggestion.
8. **Cabinet hardware** — small amber or teal status lights on some cabinet faces. Barely visible dots in the dark mid-ground. PMCA filing cabinets are electronic — some have indicator lights on the locked drawers.

### Excluded (must not appear)
- People, figures, silhouettes of people anywhere
- Multiple windows or large sources of exterior light
- Readable signage, text on cabinets, PMCA logos
- Bright environmental lighting (overhead fluorescent strips, etc.)
- Modern office furniture or aesthetics
- Any warm light from the city — the city emits teal, not amber
- Papers, documents, or clutter on the foreground desk (the desk is empty and waiting)

---

## Required Lore Elements

The PMCA Central Archive exists within the Administrative Core district of Veyr. The archive is deep within the building — no daylight reaches it. The single window that exists in this image is an anomaly, a narrow slit in the building's exterior. Through it, the player can see that the outside world still exists.

The city of Veyr at night is teal and cold. Helix Meridian's infrastructure towers transmit in the teal frequency. The rain makes every surface reflect. Buildings are dark silhouettes with sparse warm amber points of light — individual windows, terminal glow, street level amber.

The PMCA is not an evil-looking institution. It is correct-looking. The filing cabinets are orderly. The desk is clean. The lamp is on. The institution is doing what it is supposed to do. What it is supposed to do is the problem.

---

## Camera Angle

**Ground-level perspective looking down the corridor of filing cabinets.** The camera is approximately at desk-height (standing person's eye level, about 150cm), positioned slightly to the left, looking slightly right toward the vanishing point. This creates:
- A strong linear perspective with the cabinet rows converging to the distance
- The foreground desk occupies the lower-left quadrant
- The window in the background is visible down the corridor
- The ceiling is at the top of frame, barely visible
- The floor recedes to the vanishing point

This is a location shot, not a studio composition. The camera position creates the feeling of standing in the doorway of the archive, seeing the room for the first time.

---

## Composition Notes

The main menu has two functional zones:
- **Left side (~40%):** Game title "DEAD LETTER OFFICE" and subtitle text in terminal amber
- **Right side (~40%):** Menu buttons (BEGIN SHIFT, CHAPTER SELECT, SETTINGS, etc.)

The background must support text readability in both zones without the game adding additional overlays.

**Left third — darkest.** The game title text is amber on this area. The background must be very dark here — no bright elements, no amber light sources. The filing cabinets in the left foreground/mid-ground provide the darkest areas. This is where the ambient darkness of the archive is strongest.

**Centre — depth focus.** The vanishing point and the corridor. The lamp on the foreground desk provides the only warm element here. The window in the far distance provides the teal cold light. This area has the most depth and visual interest but is also somewhat covered by UI elements.

**Right side — slightly less dark but still subdued.** The menu buttons render in amber over this area. Some ambient teal from the distant window can bleed into the right side, creating a gradient-of-atmosphere from warm amber (left, lamp) to cold teal (right, city). This must be done with hard edges between tones, not a smooth gradient.

**Foreground/background hierarchy:**
- Foreground desk: brightest element (lamp cone), clearest detail
- Mid-ground cabinets: dark and repetitive, recede into shadow
- Far background window: small, cold teal, the only exterior light
- Everything else: near-black

**Scale is intentional.** The desk should appear small relative to the corridor of cabinets. The human scale is dwarfed by the institutional scale. This is not an accident — it is the image's argument about the world.

---

## UI-Safe Areas

### Left-side text zone (game title)
This area renders "DEAD LETTER OFFICE" in large terminal amber text and the subtitle underneath. Background must be:
- Average luminance < 15% in this zone (very dark)
- No amber elements in this zone — the amber title text must have maximum contrast
- Filing cabinet faces or open dark space preferred here

### Right-side button zone (menu buttons)
This area renders the four menu buttons as amber-outlined rectangles with amber text. Background must be:
- Average luminance < 20% in this zone (dark)
- No light sources competing with button visibility
- Cold teal glow from the distant window is acceptable if dim

### Centre-top zone (not covered by primary UI)
The vanishing point, upper ceiling area. Should be visually interesting but not so bright that it distracts from the menu elements.

---

## Resolution Requirements

| Stage | Canvas | Dimensions | Notes |
|---|---|---|---|
| ComfyUI generation | 1280×592 px | 2.16:1 (matches game aspect ratio) | Preferred for aspect ratio accuracy |
| DiffusionBee generation | 1344×768 px | 1.75:1 (per AssetProductionPlan) | Standard pipeline |
| Post-processing target | — | Posterize lvl 8, palette correct, contrast boost | Average luminance < 30% overall; < 15% left third |
| Final export | 2668×1500 px or 2560×1184 px | — | Upscale via Lanczos or RealESRGAN |
| Xcode import | `bg_main_menu@2x.png` | Match export dimensions | 2x slot in imageset |

---

## ComfyUI Generation Prompt

### Positive Prompt
```
PMCA government archive interior, 1990s DOS PC game background art, Flashback 1992 game aesthetic, Papers Please art style, bureaucratic dystopia, vast institutional space

ground-level perspective inside vast government filing archive, looking down long corridor, strong linear perspective, vanishing point visible in upper centre, rows of identical dark metal filing cabinets receding to vanishing point on both sides, institutional repetition, the cabinets stretch to infinite distance

single plain dark institutional desk in foreground slightly left of centre, empty desk no objects except one amber desk lamp lit casting sharp cone of warm amber light on desk surface, no chair visible, waiting empty

single tall narrow window in far background right of centre, very small in frame showing night city exterior through window, dark city silhouette with teal cold light on building tops sparse amber window lights distant, rain visible outside

very dark interior, near-black ambient environment, amber warm light from single foreground desk lamp only warm source, cold teal glow from distant window only cold source, dark institutional suspended ceiling barely visible at top, dark floor with faint amber reflection

flat shading with hard shadow edges, discrete colour bands no gradients, limited colour palette, near-black dominant environment, amber and teal accent light, no overhead fluorescent lighting, deep shadows

limited 14 colour palette, posterised graphic quality, deep navy background #070D14, dark cabinet forms #050810, steel blue surfaces #405873, terminal amber lamp glow #FFB533, PMCA teal city light #00B5C9

no photorealism, no smooth gradients, no 3D rendering, hard graphic style, Another World 1991 environment aesthetic, dark oppressive institutional architecture, human scale dwarfed by institutional scale
```

### Negative Prompt
```
photorealistic, hyperrealistic, subsurface scattering, ambient occlusion, specular highlights, smooth gradients, soft lighting, cinematic lighting, 3d render, vray render, octane render, blender, studio lighting

bright interior lighting, overhead lights, fluorescent ceiling panels, warm ambient fill, well-lit room, inviting atmosphere

person, human figure, silhouette of person, shadow of person

warm city colours through window, yellow city lights dominant, bright exterior, daylight through window, multiple windows, large exterior view

photorealistic metal surface, realistic filing cabinet detail, chrome hardware, wood grain photorealistic, concrete texture photorealistic

text visible on cabinets, signs, logos, labels readable, PMCA text visible

modern office elements, ergonomic furniture, computer monitor flat screen, potted plant, artwork, personal decoration, clutter

anime style, cartoon style, cell shading, comic book, watercolour, oil painting

bright colours, saturated colours, purple, magenta, bright orange, neon colours, cheerful, warm cosy

glossy floor reflection prominent, mirror floor, wet glass reflections
```

---

## Generation Settings

| Setting | Value | Rationale |
|---|---|---|
| Model | DreamShaper XL Turbo | Stylised; resists photorealism |
| Canvas | 1280×592 px (ComfyUI) or 1344×768 px (DiffusionBee) | Match game aspect ratio where possible |
| Steps | 10–12 | Environment needs slightly more than portrait |
| CFG / Guidance | 2.5–3.0 | Lower end of range to maintain graphic, non-photographic quality |
| Sampler | Euler or DPM++ 2M Karras | Stable for environments |
| Seed policy | Random first 8 batches; lock on best composition with correct perspective | Perspective must be correct; iterate more than for desk background |
| Batch count | 8–10 | Linear perspective corridor is difficult to get right; plan for more attempts |

**Known generation challenge:** Linear perspective corridors in AI generation frequently produce bent, misaligned, or asymmetric results. The vanishing point should converge clearly. If multiple batches produce bent corridor lines, add `straight perspective lines, correct vanishing point, architectural accuracy` to the positive prompt. If the corridor is still distorted, consider using ControlNet with a depth map or linework as input.

---

## Post-Processing Sequence (Pixelmator)

1. Export PNG from ComfyUI
2. **Posterize** — Effects → Stylize → Posterize, Level **8**
3. **Palette correction:**
   - Left third: confirm near-black dominance. Darken if average luminance exceeds 15%. No amber elements in this zone.
   - Window area: ensure exterior teal glow stays within `#00B5C9` family, desaturated. If the city view is too warm (orange city lights), correct toward teal.
   - Desk lamp cone: push amber toward `#FFB533`. Should be warm but not bright.
4. **Contrast boost** — Levels: push blacks to `#050810`; keep highlights in the amber lamp cone below 80% luminance
5. **Left-zone luminance check** — select the left 40% of the canvas. Histogram must show average luminance below 15% in this region. If over 15%, apply a darkening Curves adjustment to the left third only.
6. **Histogram check** — whole image average luminance below 30%
7. **Silhouette test** — flatten to black on white. The desk, the lamp cone, the filing corridor, and the window must all read as distinct, separate shapes
8. **Upscale** — Lanczos to 2668×1500 px (or 2560×1184)
9. **Final overlay simulation** — in Pixelmator, temporarily add a text layer "DEAD LETTER OFFICE" in amber on the left third. Confirm the title text is readable. If not, darken the left zone further.

---

## Approval Criteria

The background is approved when:
- [ ] The environment is immediately readable as a vast institutional filing archive
- [ ] Strong linear perspective with cabinet rows converging to a clear vanishing point
- [ ] Single amber desk lamp is the only warm light source
- [ ] Single cold teal glow is visible through the far window
- [ ] The desk in the foreground is empty and waiting
- [ ] Average luminance below 30% (histogram verified)
- [ ] Left third luminance below 15% (text zone verified)
- [ ] No smooth gradients — all shading hard-edged
- [ ] The scale contrast between the desk and the archive is visible and intentional
- [ ] Terminal amber text placed over the left third reads at contrast ratio 4.5:1 or higher
- [ ] No photorealistic elements survived post-processing
- [ ] Maximum 16 distinct colours

---

## Comparison of Both Assets

| Attribute | bg_desk_office | bg_main_menu |
|---|---|---|
| Space | Intimate — one desk | Vast — industrial archive |
| Light sources | 2 (lamp + CRT) | 2 (lamp + window) |
| Dominant emotion | Oppressive calm | Institutional awe |
| Depth | Shallow — desk to wall | Deep — desk to horizon |
| Player relationship | This is MY workspace | This is the world I'm entering |
| Warm/cold balance | More amber (the work) | More teal (the city) |
| Luminance priority | Uniform darkness | Left zone darkest |
| Most important element | The CRT and lamp | The empty desk + window |

Both backgrounds share the same palette, the same hard-edge shading rules, the same luminance ceiling, and the same prohibition on photorealistic rendering. They should feel like they belong to the same world — because they are the same building, on different days, at different scales.

---

*Art brief produced 2026-06-02. All visual direction derived from ArtStyleGuide.md v1.0, AssetProductionPlan.md v4.0, CANON.md, DLOColors.swift, and the DeskScene/MainMenuScene layout code. No art produced. Document is ready for immediate production use.*
