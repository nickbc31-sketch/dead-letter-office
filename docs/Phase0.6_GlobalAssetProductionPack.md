# Phase 0.6 — Global Asset Production Pack

**Dead Letter Office** | Canonical production roadmap  
**Status:** Approved 2026-06-05  
**Authority:** `docs/CANON.md`, `docs/ArtStyleGuide.md`, `docs/AssetProductionPlan.md`, `docs/design/Phase0.5_FullAssetAudit_June2026.md`  
**Scope:** Every **P0** and **P1** asset from the approved audit — documentation only. No code. No Chapter 4 implementation.  
**Goal:** Systematic artwork and audio creation before Chapter 4 engineering begins.

---

## How to use this document

1. Work **Production Order** (bottom of document) — Phase A first, then B → C → D.
2. For visual assets: generate in **ComfyUI** → post-process in **Pixelmator** per `docs/ArtStyleGuide.md` → import to `DeadLetterOffice/Assets.xcassets`.
3. For audio: source from **Epidemic Sound** → trim/normalise → drop into `DeadLetterOffice/` (Xcode target membership).
4. Review candidates in `assets/assets/Portraits/generated/` before promoting to `assets/assets/Portraits/Approved/`.
5. Locked portraits: **do not regenerate**. Record seeds in `docs/Art/ApprovedPortraitSettings.md`.

### Production method key

| Method | When to use |
|--------|-------------|
| **ComfyUI generated** | Portraits, backgrounds, parallax, sprites |
| **Manually edited** | Post-processing (posterize, palette, resize), AppIcon polish, audio trim/layer |
| **Epidemic Sound sourced** | All music and SFX |
| **UI generated** | Procedural in-code UI (virtual pad, CRT, documents) — no asset file |
| **Approved — locked** | Canon portrait already finalised — no generation |

### ComfyUI global defaults (all visual assets)

| Setting | Value |
|---------|-------|
| **Checkpoint** | DreamShaper XL Turbo (`dreamshaperXL10TurboDPMSDE.safetensors` or equivalent SDXL Turbo) |
| **Sampler** | Euler or DPM++ SDE |
| **Scheduler** | Normal |
| **VAE** | SDXL default VAE |
| **Upscale** | Lanczos (backgrounds) / nearest-neighbour only (sprites) |

**Do not use** for portraits or sprites: Juggernaut XL, Cyber Realistic, Epic Realism XL, RealViz XL.

### Global Style Lock (paste verbatim into every visual prompt)

```
DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos
```

### Shared negative prompt (append to every visual generation)

```
photorealistic, hyperrealistic, glamour portrait, beauty portrait, instagram portrait, subsurface scattering, soft skin, detailed pores, realistic hair strands, bokeh, depth of field, soft lighting, cinematic lighting, ambient occlusion, specular highlights, smooth gradients, 8k, high resolution photography, studio lighting, realistic textures, 3d render, vray, octane render, anime, manga, cartoon, comic book, western animation, cel shading anime style, glossy, smooth shading, bright saturated colours, neon, purple, magenta, deformed, extra limbs, bad anatomy, watermark, signature, text, logo
```

### Standard post-processing (all visuals)

1. Posterize (level 6–8 backgrounds, 5–7 portraits, 4–5 sprites)  
2. Palette correction toward game hex values (`#070D14`, `#00B5C9`, `#FFB533`, etc.)  
3. Contrast boost — average background luminance **below 30%**  
4. Silhouette test (black on white — subject readable)  
5. Resize to target dimensions (Lanczos backgrounds; nearest-neighbour sprites)

### Audio bundle notes

- **Music:** MP3, 44.1 kHz, 128–192 kbps, seamless loops where noted  
- **SFX:** WAV, 44.1 kHz, 16-bit  
- **Filename warning:** Code calls `ambient_menu` in `MainMenuScene.swift`. Export menu music as **`ambient_menu.mp3`** (not `ambient_mainmenu.mp3`).

---

## Part 1 — P0 & P1 Portraits

Standard: **392 × 392 px @2x**, 1:1, ComfyUI canvas **1024 × 1024**, CFG **2.5**, Steps **10**, batch **8** (portraits).

---

### portrait_mara

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Protagonist DialogueScene portrait Ch1–8 |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_mara.imageset/` |
| **Placeholder currently used** | Approved catalog asset |
| **Production method** | **Approved — locked** (ComfyUI origin; do not regenerate) |

**Character summary:** Mara Venn, 31, East Asian woman, PMCA Review Clerk, Veyr 2147. Sharp cheekbones, strong jaw, tired intelligent eyes. Bureaucratic survivor, not heroic.

**Required expression:** Controlled neutral; slight jaw tension; no smile.

**Clothing notes:** Dark steel-blue PMCA government clerk uniform, high collar, two small gold collar pins. Simplified folds — silhouette over detail.

**Lighting notes:** Hard teal rim upper-left (`#00B5C9`); hard amber fill upper-right (`#FFB533`). Hard terminator line on face.

**Canon restrictions:** Do not regenerate. Reference `assets/assets/Portraits/Approved/mara_venn_v1_approved.png`. Defines lighting for all other portraits. Medium blue-grey background — not pure black.

**ComfyUI:** N/A — locked canon.

---

### portrait_calyx

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Antagonist DialogueScene — Ch1, 3–4, 7–8 |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_calyx.imageset/` |
| **Placeholder currently used** | Approved catalog asset |
| **Production method** | **Approved — locked** |

**Character summary:** Director Calyx — East Asian man, late thirties to early forties. Institutional authority outside PMCA uniform; civilian power.

**Required expression:** Intense controlled direct gaze. Cold, not theatrical.

**Clothing notes:** Dark near-black civilian authority suit and tie. Not PMCA uniform — distinct from Mara.

**Lighting notes:** Same teal/amber direction as Mara; **more dramatic shadow contrast** on cheekbones and brow.

**Canon restrictions:** Approved design supersedes older grey-hair description. Black hair, no beard. Do not regenerate.

**ComfyUI:** N/A — locked canon.

---

### portrait_audit_voice

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Every chapter intro; abstract surveillance entity |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_audit_voice.imageset/` |
| **Placeholder currently used** | In catalog — verify against style reference before locking |
| **Production method** | ComfyUI generated → manually edited |

**Character summary:** The Audit Voice — no face, no body. Automated PMCA overseer. Geometric, bureaucratic, invasive calm.

**Required expression:** N/A — featureless mask; single amber horizontal slit implies observation.

**Clothing notes:** N/A

**Lighting notes:** Amber slit `#FFB533`; faint teal circuit at edges. Background absolute black `#050810`.

**Canon restrictions:** No human features (no skull, eyes, mouth, robot face). No religious or horror imagery.

**ComfyUI prompt:**
```
geometric abstract surveillance mask, completely smooth featureless dark obsidian surface, single narrow horizontal amber glowing slit where eyes would be, faint teal circuit pattern barely visible at edges, floating in absolute black void, no mouth no nose no ears no hair no body, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, flat graphic design, 5-colour palette maximum, strong geometric silhouette, cold bureaucratic presence, square composition centred
```

**Asset-specific negative prompt:**
```
human face, skull, robot face, mechanical parts, eyes, mouth, teeth, body, hands, hair, background detail, complex shapes, multiple objects
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1024 × 1024 |
| CFG | 2.5 |
| Steps | 10 |
| Batch count | 10 |

**Post-processing:** Posterize level 5 → background `#050810` → amber slit `#FFB533` → resize 392 × 392 Lanczos.

---

### portrait_jun_vale

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Resistance contact — Ch2+, dialogue-heavy Ch7–8 |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_jun_vale.imageset/` |
| **Placeholder currently used** | In catalog — formal v1 approval pending; colour-hash fallback if missing |
| **Production method** | ComfyUI generated → manually edited |

**Character summary:** Jun Vale, 29, Southeast Asian man. Officially declared dead; active in maintenance systems. Quiet Choir contact.

**Required expression:** Guarded, wary; underlying urgency. Watchful — not combat-ready.

**Clothing notes:** Worn dark civilian jacket over collared layer. Resistance underground aesthetic — no weapons visible, no combat gear.

**Lighting notes:** Standard portrait lighting (teal upper-left, amber upper-right). Medium blue-grey background.

**Canon restrictions:** No government uniform. No cheerful expression. Small chin scar is canonical detail.

**ComfyUI prompt:**
```
Southeast Asian man mid-thirties, near-frontal portrait, cropped dark hair, sharp watchful eyes, small scar on chin, worn dark civilian jacket over collared layer, guarded wary expression with underlying urgency, resistance underground aesthetic, solid medium blue-grey background, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, flat colour illustration, hard-edge shadow planes, discrete tonal bands, no gradient blending, matte surfaces, bust composition
```

**Asset-specific negative prompt:**
```
weapons visible, combat gear, cheerful expression, government uniform, soft background, gradient, long hair
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1024 × 1024 |
| CFG | 2.5 |
| Steps | 10 |
| Batch count | 8 |

**Post-processing:** Standard portrait pipeline; match approved Mara/Calyx lighting bands.

---

### portrait_elias_venn

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Mara's missing brother — Ch5–8 Elias thread |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_elias_venn.imageset/` |
| **Placeholder currently used** | Procedural colour-hash placeholder |
| **Production method** | ComfyUI generated (img2img from Mara) → manually edited |

**Character summary:** Elias Venn — East Asian man, mid-twenties, network engineer. Officially declared dead 2142. Sibling resemblance to Mara.

**Required expression:** Fear and confusion; intelligent eyes. Transmission artifact quality — not horror zombie.

**Clothing notes:** Plain dark collar shirt. No PMCA uniform.

**Lighting notes:** Faint teal rim upper-left; very dark near-black background almost blending with figure.

**Canon restrictions:** Sibling resemblance to Mara (angular features). Ghostly ~85% opacity after post — not fully opaque. No gore, no zombie styling. Male only.

**ComfyUI prompt:**
```
flat shading portrait, young East Asian man mid-twenties, similar angular features to his sister, short dark hair, intelligent eyes carrying fear and confusion, plain dark collar shirt, slightly desaturated skin tones suggesting a digital transmission artifact, ghostly quality to the image, hard faint teal rim from upper left, very dark near-black background almost blending with figure, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, 8-colour limited palette, Papers Please character portrait quality
```

**Asset-specific negative prompt:**
```
zombie, horror, gore, solid fully-opaque appearance, cheerful, colourful background, young girl, female
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1024 × 1024 |
| CFG | 2.5 |
| Steps | 10 |
| Batch count | 8 |
| **Img2img** | Yes — `portrait_mara` input at **0.20** strength |

**Post-processing:** Standard portrait pipeline → reduce figure opacity to **~85%** → background near-pure black.

---

### portrait_pmca_director

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Senior PMCA authority — Ch4–6 |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_pmca_director.imageset/` |
| **Placeholder currently used** | Approved catalog asset |
| **Production method** | **Approved — locked** |

**Character summary:** Older man, late fifties. Grey hair combed to side, grey mustache, heavyset authoritative bearing. **Distinct from Director Calyx.**

**Required expression:** Controlled official expression. Institutional weight.

**Clothing notes:** Dark near-black civilian authority suit and tie.

**Lighting notes:** Standard teal/amber portrait lighting. Medium blue-grey background.

**Canon restrictions:** Do not regenerate. Not Calyx — older, grey hair, mustache, heavier build.

**ComfyUI:** N/A — locked canon.

---

### portrait_saint_orra

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Historical resistance figure — Ch6, Ch8 C24 |
| **Target dimensions** | 392 × 392 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Portraits/portrait_saint_orra.imageset/` |
| **Placeholder currently used** | Approved catalog asset |
| **Production method** | **Approved — locked** |

**Character summary:** Saint Orra — woman, forties. Executed 2130; officially erased. Quiet Choir historical anchor.

**Required expression:** Fierce quiet conviction; calm absolute certainty.

**Clothing notes:** Plain dark worn clothing — years in hiding. Faint scarring on neck.

**Lighting notes:** Hard teal rim upper-left; hard amber upper-right. Near-black background `#070D14`.

**Canon restrictions:** No halo, wings, religious symbols, supernatural glow. Human resistance leader only.

**ComfyUI:** N/A — locked canon.

---

## Part 2 — P0 & P1 Full-Screen Backgrounds

Standard: **2668 × 1500 px @2x**, 16:9. ComfyUI canvas **1344 × 768**, CFG **3.0**, Steps **10**, batch **6**.

---

### bg_desk_office

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Primary DeskScene backdrop Ch1–8 (preferred over procedural) |
| **Target dimensions** | 2668 × 1500 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_desk_office.imageset/` |
| **Placeholder currently used** | Procedural dark fill; falls back if `bg_terminal_wallpaper` absent |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
retro game environment background, institutional clerk desk from slight overhead angle, dark worn wooden surface, worn leather desk blotter, heavy CRT terminal with amber phosphor glow, single amber desk lamp cone of light, wire inbox tray, dark filing shelf wall in background, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, limited 12-colour palette, flat graphic shading, 1990s PC game background art, Flashback game aesthetic, no people, wide landscape composition, dark left third for title overlay
```

**Asset-specific negative prompt:**
```
photorealistic wood grain, realistic material rendering, detailed textures, modern office furniture, clean surfaces, people visible, computer screens with content
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1344 × 768 |
| CFG | 3.0 |
| Steps | 10 |
| Batch count | 6 |

**Post-processing:** Posterize 8 → luminance below 30% → upscale Lanczos to 2668 × 1500.

**Ch4 gate note:** Either ship this **or** confirm `bg_terminal_wallpaper` as interim desk art.

---

### bg_main_menu

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | MainMenuScene first impression |
| **Target dimensions** | 2668 × 1500 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_main_menu.imageset/` |
| **Placeholder currently used** | In catalog; procedural rain overlay if asset load fails |
| **Production method** | ComfyUI generated → manually edited (verify in build) |

**ComfyUI prompt:**
```
retro game environment background, vast brutalist government archive interior at night, rows of identical dark filing cabinets receding to vanishing point, single amber overhead lamp cone on empty desk in foreground, tall narrow window far background showing teal-lit dark city skyline, heavy atmospheric dark, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, limited 10-colour palette, flat graphic shading, 1990s PC game environment art, Papers Please office aesthetic, left third darkest for menu title, no people
```

**Asset-specific negative prompt:**
```
cluttered foreground, bright windows, modern furniture, photorealistic materials, gradient sky
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1344 × 768 |
| CFG | 3.0 |
| Steps | 10 |
| Batch count | 6 |

**Post-processing:** Posterize 8 → left third luminance below 20% → upscale to 2668 × 1500.

---

### bg_terminal_wallpaper

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Interim DeskScene atmosphere; used when present (DeskScene prefers this over `bg_desk_office`) |
| **Target dimensions** | 2668 × 1500 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_terminal_wallpaper.imageset/` |
| **Placeholder currently used** | In catalog |
| **Production method** | ComfyUI generated → manually edited (verify quality) |

**ComfyUI prompt:**
```
abstract dark texture, near-black government terminal wallpaper, faint teal circuit trace grid barely visible, amber phosphor glow at edges, extreme low contrast institutional surface, CRT era bureaucratic terminal, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, 6-colour maximum palette, flat graphic, wide landscape format, centre darker for document overlay
```

**Asset-specific negative prompt:**
```
bright colours, readable text, logos, photorealistic screen, modern UI, gradient vignette
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1344 × 768 |
| CFG | 2.0 |
| Steps | 8 |
| Batch count | 4 |

**Post-processing:** Posterize 4–6 → average luminance below 25% → upscale to 2668 × 1500.

---

### bg_chapter_complete

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | ChapterCompleteScene post-chapter card (shared ×8) |
| **Target dimensions** | 2668 × 1500 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_chapter_complete.imageset/` |
| **Placeholder currently used** | Procedural black |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
retro game background, looking through tall narrow institutional window at night, dark rain-soaked dystopian city below, amber street lights and teal transmission towers in fog, dark institutional concrete window frame interior, reflection of desk lamp in glass, melancholic quiet atmosphere, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, limited 10-colour palette, flat graphic shading, 1990s PC game environment, wide landscape format, centre darker for text overlay, no people
```

**Asset-specific negative prompt:**
```
bright city lights, neon signs, photorealistic glass reflection, clear sky, cheerful mood
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1344 × 768 |
| CFG | 3.0 |
| Steps | 10 |
| Batch count | 6 |

**Post-processing:** Posterize 8 → upscale to 2668 × 1500.

---

### AppIcon

| Field | Value |
|-------|-------|
| **Production priority** | P0 (store) |
| **Purpose** | iOS home screen / App Store |
| **Target dimensions** | 1024 × 1024 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/AppIcon.appiconset/` |
| **Placeholder currently used** | In catalog (untracked copy also at `Assets/assets/AppIcon/`) |
| **Production method** | Manually edited (from ComfyUI base or vector) |

**ComfyUI prompt (if regenerating base):**
```
app icon design, dark navy square, stylised rubber stamp impression oval border, amber terminal slit accent, PMCA bureaucratic aesthetic, DEAD LETTER OFFICE STYLE, flat graphic, limited 8-colour palette, hard edges, no text, no letters, no photorealism, centred simple symbol readable at 60 pixels
```

**Negative prompt:** `text, letters, words, logo, photorealistic, gradient, bright colours, complex detail`

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1024 × 1024 |
| CFG | 2.5 |
| Steps | 10 |
| Batch count | 12 |

**Post-processing:** Posterize → silhouette test at 60 px → export all AppIcon sizes via Xcode asset catalog.

---

## Part 3 — P0 & P1 Platform Parallax Backgrounds

Standard strip: **6144 × 800 px @2x**. ComfyUI canvas **1344 × 448**, CFG **2.5**, Steps **10**, batch **6**. Generate far/mid/near in **one session** with shared seed family.

### Global parallax trio

---

#### bg_city_far

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Layer type** | Far skyline |
| **Parallax depth** | 0.1 (barely moves) |
| **Visual theme** | Veyr megacity at night — universal skyline |
| **Reuse opportunities** | All platform levels Ch1–8 as far layer default |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_city_far.imageset/` |
| **Placeholder currently used** | Procedural gradient silhouette |
| **Production method** | ComfyUI generated → manually edited (tile extend) |

**ComfyUI prompt:**
```
pixel art game background layer, far city skyline silhouette strip, vast dystopian megacity at night seen from below, jagged skyscraper silhouettes against very slightly lighter dark teal-navy sky, sparse amber pinprick lights in building faces, heavy smog, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, 3-colour palette maximum (near-black buildings, dark navy sky, amber pinpoints), flat graphic silhouette style, Another World 1991 game aesthetic, ultra-wide panoramic strip format, no foreground elements, low horizon line
```

**Asset-specific negative prompt:**
```
detailed buildings, windows with detail, people, vehicles, foreground objects, more than 4 colours, gradient sky, clouds
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 1344 × 448 |
| CFG | 2.5 |
| Img2img tile extend | 0.40 strength |
| Batch count | 6 |

**Post-processing:** Posterize 4 → exactly 3 colours (`#050810`, `#0D1420`, `#FFB533`) → extend to 6144 px wide → height 800 px.

---

#### bg_facility_mid

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Layer type** | Mid industrial |
| **Parallax depth** | 0.4 |
| **Visual theme** | PMCA sorting facility / maintenance infrastructure |
| **Reuse opportunities** | Ch1 P01, Ch2 P02, Ch4 P04 default mid layer |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_facility_mid.imageset/` |
| **Placeholder currently used** | Procedural bands |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, industrial sorting facility mid-ground, dark mechanical conveyor structures and sorting racks receding into shadow, amber emergency lighting strips on ceiling, teal-lit cable trays overhead, deep atmospheric dark, brutalist concrete columns, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, 6-colour palette, flat graphic shading, Another World 1991 game aesthetic, ultra-wide panoramic strip, no sky visible, industrial ceiling only, no people
```

**Asset-specific negative prompt:**
```
photorealistic machinery, detailed textures, bright colours, sky, clouds, people, modern clean equipment
```

**Post-processing:** Posterize 6 → extend 6144 × 800 → must match `bg_city_far` environment family.

---

#### bg_facility_near

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Layer type** | Near foreground |
| **Parallax depth** | 0.7 |
| **Visual theme** | Corroded pipes, floor plates, cable conduits |
| **Reuse opportunities** | Ch1–2, Ch4 default near layer |
| **Target dimensions** | 6144 × 800 px (**upper 50% transparent**) |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_facility_near.imageset/` |
| **Placeholder currently used** | Procedural pipe shapes |
| **Production method** | ComfyUI generated → manually edited (alpha mask) |

**ComfyUI prompt:**
```
pixel art game foreground layer, bottom half only, large dark corroded metal pipes and cable conduits running horizontally, worn metal floor plates, amber indicator lights on wall panels, deep shadow pools, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos, 5-colour palette, flat graphic silhouettes, Another World 1991 game aesthetic, content in BOTTOM HALF ONLY, top half is empty space, ultra-wide panoramic strip, no people
```

**Asset-specific negative prompt:**
```
sky, upper half content, people, vehicles, bright colours, photorealistic materials, gradient
```

**Post-processing:** Delete upper 50% → soft alpha fade 50–55% height → extend 6144 px → PNG with alpha.

---

### Chapter-specific parallax (P1)

Use same technical spec as `bg_facility_mid` unless noted. Replace mid/near layers per level JSON.

---

#### bg_housing_mid (Ch3)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Mid residential |
| **Parallax depth** | 0.4 |
| **Visual theme** | Soulprint housing block — bureaucratic residential corridors |
| **Reuse opportunities** | `level_ch3.json` only; warmer than facility palette |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_housing_mid.imageset/` |
| **Placeholder currently used** | Falls back to `bg_facility_mid` if missing |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, dystopian housing block interior mid-ground, long institutional corridor with numbered unit door silhouettes, bulletin board shape on wall, muted residential palette slightly warmer than industrial, cold fluorescent strip lighting at ceiling, sealed unit notice shapes on doors no readable text, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no text, no logos, 6-colour palette, ultra-wide panoramic strip, no people
```

**Post-processing:** Posterize 6 → extend 6144 × 800.

---

#### bg_housing_near (Ch3)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Near residential foreground |
| **Parallax depth** | 0.7 |
| **Visual theme** | Housing block foreground — sealed notices, duct work |
| **Reuse opportunities** | `level_ch3.json` only |
| **Target dimensions** | 6144 × 800 px (upper portion transparent) |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_housing_near.imageset/` |
| **Placeholder currently used** | Falls back to `bg_facility_near` |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game foreground layer, housing block near ground, sealed eviction notice paper shapes on wall no readable text, open duct work upper right area, worn wall panels, amber maintenance light, bottom half content only top half empty, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, hard edge shadows, no gradients, posterized, bureaucratic dystopia, 5-colour palette, ultra-wide panoramic strip, no people, no text
```

**Post-processing:** Alpha mask upper 50% as per `bg_facility_near`.

---

#### bg_meridian_mid (Ch5)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Mid corporate |
| **Parallax depth** | 0.4 |
| **Visual theme** | Helix Meridian premium — sterile glass, too clean |
| **Reuse opportunities** | Ch5 desk atmosphere reference; future P05 if added |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_meridian_mid.imageset/` |
| **Placeholder currently used** | `bg_facility_mid` fallback |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, Helix Meridian premium grief services interior mid-ground, clean glass partition silhouettes, pristine curved architectural forms, sterile corporate lighting, almost no texture too perfect surfaces, subtle teal glass reflections, oppressive luxury bureaucracy, DEAD LETTER OFFICE STYLE, flat graphic shading, limited 8-colour palette, hard edges, ultra-wide panoramic strip, no people, no logos, no readable text
```

**Post-processing:** Posterize 6 → keep luminance slightly higher than facility (corporate "clean") but still below 35%.

---

#### bg_train_mid (Ch6)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Mid transit |
| **Parallax depth** | 0.4 |
| **Visual theme** | Black Mail Train — **reduced scope: 2 carriages + siding** |
| **Reuse opportunities** | `level_ch6.json` only |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_train_mid.imageset/` |
| **Placeholder currently used** | `bg_facility_mid` fallback |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, automated underground data mail train mid-ground, two dark cargo carriage silhouettes on siding track, cable conduits and signal boxes, amber platform edge lights, teal data relay towers, industrial transit tunnel, DEAD LETTER OFFICE STYLE, flat graphic, 6-colour palette, ultra-wide panoramic strip, reduced scope not endless train, no people, no readable text
```

---

#### bg_undercity_mid (Ch7)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Mid refuge |
| **Parallax depth** | 0.4 |
| **Visual theme** | Quiet Choir undercity — handmade warmth within darkness |
| **Reuse opportunities** | `level_ch7.json` — minimal platform (~2,500–3,500 pt) |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_undercity_mid.imageset/` |
| **Placeholder currently used** | `bg_facility_mid` fallback |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, underground refuge mid-ground, improvised shelter structures in maintenance cavern, hanging fabric and cable rigging silhouettes, warm amber lantern pools contrasting cold teal tunnel, human-scale handmade details not institutional, Quiet Choir hidden community aesthetic, DEAD LETTER OFFICE STYLE, flat graphic, 8-colour palette with slightly warmer mid-tones, ultra-wide panoramic strip, no people visible, no text
```

---

#### bg_central_archive_mid (Ch8)

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Layer type** | Mid archive |
| **Parallax depth** | 0.4 |
| **Visual theme** | Central Archive infiltration (P08 setup only — climax is desk C24) |
| **Reuse opportunities** | `level_ch8.json` platform segment if present (~3,000–3,500 pt) |
| **Target dimensions** | 6144 × 800 px |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Backgrounds/bg_central_archive_mid.imageset/` |
| **Placeholder currently used** | `bg_facility_mid` fallback |
| **Production method** | ComfyUI generated → manually edited |

**ComfyUI prompt:**
```
pixel art game background layer, central dead letter archive mid-ground, vast shelving silhouettes receding into cold dark, amber aisle markers, teal security scanner mounting shapes, monumental bureaucratic scale, profound record storage, DEAD LETTER OFFICE STYLE, flat graphic, 6-colour palette, ultra-wide panoramic strip, no people, no readable text
```

---

## Part 4 — P1 Character Sprites

---

### mara_silhouette

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | MaraPlayerNode platform sprite |
| **Target dimensions** | 128 × 192 px @2x |
| **Folder location** | `DeadLetterOffice/Assets.xcassets/Characters/mara_silhouette.imageset/` |
| **Placeholder currently used** | Procedural teal rectangle silhouette |
| **Production method** | ComfyUI generated → manually edited (nearest-neighbour pixel pass) |

**ComfyUI prompt:**
```
pixel art game sprite, full body standing side view, slim young woman in fitted government clerk uniform, slight action-ready lean, completely flat near-black teal silhouette body, single amber rim light on right edge only, no internal detail, clean pixel edges, DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, 4-colour palette maximum, transparent background, portrait orientation, Flashback 1992 game character sprite, Another World player character aesthetic, 1990s side-scroller proportions
```

**Asset-specific negative prompt:**
```
detailed face, internal clothing detail, white background, loose pose, weapons, multiple characters, background elements, more than 4 colours
```

| ComfyUI setting | Value |
|-----------------|-------|
| Model | DreamShaper XL Turbo |
| Resolution | 512 × 768 |
| CFG | 2.5 |
| Steps | 10 |
| Batch count | 12 |

**Post-processing:** Remove background → posterize 4 → scale **down** to 64×96 logical (128×192 @2x) nearest-neighbour only.

---

## Part 5 — P0 & P1 Audio

All files: `DeadLetterOffice/` bundle root (drag into Xcode, target membership on).

---

### Music — P0

#### ambient_desk.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | DeskScene default loop — majority of runtime |
| **Suggested Epidemic Sound search terms** | `ambient tension subtle pulse`, `dark minimal electronic loop`, `office hum synth texture`, `low key dystopian electronic`, `tense ambient bureaucratic` |
| **Mood** | Low-key bureaucratic tension; room breathing; not dramatic |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** — seamless |
| **Production method** | Epidemic Sound sourced → manually edited (loop crossfade, normalise −14 LUFS integrated) |

#### ambient_menu.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | MainMenuScene — first music heard |
| **Suggested Epidemic Sound search terms** | `dark ambient synth slow`, `dystopian atmospheric drone`, `minimal ambient tension no drums`, `cold industrial ambient night`, `melancholic synth pad slow loop` |
| **Mood** | Institutional dread at rest; oppressively calm |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** — seamless |
| **Production method** | Epidemic Sound sourced → manually edited |
| **Note** | Wired as `ambient_menu` in code — use this exact filename. |

#### ambient_platform.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | PlatformScene fallback; Ch1–3 levels |
| **Suggested Epidemic Sound search terms** | `industrial ambient loop`, `dark electronic rhythmic tension`, `dystopian platform synth`, `urban underground electronic pulse`, `tension thriller electronic minimal` |
| **Mood** | Urban industrial tension; facility always running |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** — seamless |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_choir.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | Ch7 Quiet Choir — dialogue-heavy emotional release |
| **Suggested Epidemic Sound search terms** | `intimate acoustic ambient`, `underground shelter quiet`, `minimalist piano dark ambient`, `human warmth underground acoustic`, `soft dystopian ambient organic` |
| **Mood** | Warmth within darkness; human scale; harmonic intimacy |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** — seamless |
| **Production method** | Epidemic Sound sourced → manually edited |
| **Note** | P0 in audit for Ch7 ship; source in Phase C before Ch7, but prioritise early if batching ES sessions. |

---

### Music — P1

#### chapter_complete.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | ChapterCompleteScene one-shot |
| **Suggested Epidemic Sound search terms** | `melancholic ambient stinger`, `reflective cinematic short`, `sad resolution short ambient`, `emotional moment minimal stinger`, `quiet dramatic sting` |
| **Mood** | Melancholic resolution; door closing |
| **Duration target** | 15–25 s |
| **Loop requirement** | **No** — one-shot |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_ending.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | EndingScene — all three endings share one track |
| **Suggested Epidemic Sound search terms** | `cinematic ambient ending`, `emotional drone slow evolving`, `consequence ambient dark`, `dystopian resolution atmospheric`, `slow burn ambient melancholy` |
| **Mood** | Consequence in present tense; works for Broadcast, Control, Erasure |
| **Duration target** | 60–90 s |
| **Loop requirement** | Optional loop or one-shot evolve |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_desk_tense.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch4 Ghost Audit desk (`chapters.json` ambientMusicTrack) |
| **Suggested Epidemic Sound search terms** | `dark suspense minimal loop`, `tense ambient pulse`, `bureaucratic thriller underscore`, `anxiety synth loop no drums`, `paranoia ambient electronic` |
| **Mood** | Personal stakes — Mara's name on the registry; tightening unease |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** — seamless |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_meridian.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch5 Afterlife Premium desk cases |
| **Suggested Epidemic Sound search terms** | `corporate minimal ambient`, `clean futuristic synth loop`, `sterile electronic ambient`, `glass synth atmospheric minimal`, `tech dystopia clean` |
| **Mood** | Corporate sterile; beautiful and wrong |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_platform_train.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch6 Black Mail Train platform (`chapters.json`) |
| **Suggested Epidemic Sound search terms** | `train ambient loop`, `rail underground rhythmic`, `industrial transit pulse`, `mechanical carriage ambience`, `dark railway electronic` |
| **Mood** | Forbidden letters in motion; rhythmic infrastructure |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### ambient_desk_final.mp3

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch8 final shift desk — C24 climax |
| **Suggested Epidemic Sound search terms** | `final confrontation ambient`, `slow epic minimal dark`, `last decision underscore`, `weighty ambient drone`, `irreversible choice atmospheric` |
| **Mood** | Final stamp gravity; silence as weapon |
| **Duration target** | 60–90 s |
| **Loop requirement** | **Yes** |
| **Production method** | Epidemic Sound sourced → manually edited |

---

### SFX — P0

#### stamp.wav

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | All desk stamp actions (shared until differentiated) |
| **Suggested Epidemic Sound search terms** | `rubber stamp hard impact`, `office stamp thud`, `document stamp`, `heavy stamp paper`, `approval stamp foley` |
| **Mood** | Decisive bureaucratic authority; physical weight |
| **Duration target** | 0.4–0.6 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited (trim tail) |

#### page_turn.wav

| Field | Value |
|-------|-------|
| **Production priority** | P0 |
| **Purpose** | DeskScene document tab switch |
| **Suggested Epidemic Sound search terms** | `paper flip short`, `document page turn`, `paper rustle single`, `file card flip`, `soft paper sound` |
| **Mood** | Physical document handling; satisfying not loud |
| **Duration target** | 0.2–0.4 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

---

### SFX — P1

#### terminal_beep.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | PlatformScene terminal interact |
| **Suggested Epidemic Sound search terms** | `retro terminal beep`, `computer beep old`, `8-bit acknowledge tone`, `vintage computer input sound`, `amber terminal blip` |
| **Mood** | CRT-era acknowledgment |
| **Duration target** | 0.1–0.3 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### drone_alert.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | PlatformScene drone detection |
| **Suggested Epidemic Sound search terms** | `drone alert electronic`, `security alarm short`, `electronic warning sting`, `surveillance alert tone`, `alarm pulse short` |
| **Mood** | Clinical machine threat |
| **Duration target** | 0.5–1.0 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### sfx_emp_pulse.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | EMP button fire — Ch4+ platform |
| **Suggested Epidemic Sound search terms** | `electromagnetic pulse`, `energy discharge short`, `sci-fi stun burst`, `electronic burst bass`, `EMP zap` |
| **Mood** | Bureaucratic weaponised tech; brief power collapse |
| **Duration target** | 0.4–0.8 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited (may layer 2 ES clips) |

#### sfx_scanner_flag.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ghost Audit scanner zone flag trigger — Ch4 |
| **Suggested Epidemic Sound search terms** | `scanner beep warning`, `surveillance scan ping`, `security sweep tone`, `radar ping short`, `detection sweep electronic` |
| **Mood** | You're on the list — automated audit |
| **Duration target** | 0.3–0.6 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### dead_letter_arrival.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | New case / Dead Letter queue arrival |
| **Suggested Epidemic Sound search terms** | `notification tone dark`, `message arrive low tone`, `dead tone electronic short`, `arrival sound melancholic`, `low frequency alert tone` |
| **Mood** | Weight appearing; not cheerful notification |
| **Duration target** | 0.5–1.0 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### glitch_im_not_dead.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | C05 climax — "I AM NOT DEAD" desk glitch |
| **Suggested Epidemic Sound search terms** | `glitch distortion electronic`, `system error sound`, `digital corruption noise`, `corrupted data audio`, `electronic disruption burst` |
| **Mood** | System breaking; buried human impression |
| **Duration target** | 2.0–4.0 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → **manually edited** (layer 2+ clips; consider custom composite) |

#### sfx_train_door.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch6 train carriage door interact |
| **Suggested Epidemic Sound search terms** | `train door slide`, `metal door pneumatic`, `carriage door close`, `industrial door mechanism`, `transit door hiss` |
| **Mood** | Heavy automated infrastructure |
| **Duration target** | 0.6–1.2 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited |

#### glitch_orra_fragment.wav

| Field | Value |
|-------|-------|
| **Production priority** | P1 |
| **Purpose** | Ch6 Saint Orra data fragment moment |
| **Suggested Epidemic Sound search terms** | `corrupted voice fragment`, `radio static voice`, `distorted transmission`, `archival playback glitch`, `erased record static` |
| **Mood** | Erased history bleeding through |
| **Duration target** | 1.5–3.0 s |
| **Loop requirement** | **No** |
| **Production method** | Epidemic Sound sourced → manually edited (layer static + low vocal texture) |

---

## Part 6 — P0/P1 Assets Already Complete (no generation)

| Asset | Priority | Status | Action |
|-------|----------|--------|--------|
| `portrait_mara` | P0 | Locked | Verify catalog import only |
| `portrait_calyx` | P0 | Locked | Verify catalog import only |
| `portrait_pmca_director` | P1 | Locked | Verify catalog import only |
| `portrait_saint_orra` | P1 | Locked | Verify catalog import only |
| `portrait_audit_voice` | P0 | In catalog | QA against style reference; lock if pass |
| `portrait_jun_vale` | P0 | In catalog | Formal v1 approval + wire dialogue JSON |
| `bg_main_menu` | P0 | In catalog | Build verification |
| `bg_terminal_wallpaper` | P1 | In catalog | DeskScene QA |
| `AppIcon` | P0 | In catalog | Store export sizes |

---

## Production Order

Work top-to-bottom within each phase. Do not start Chapter 4 engineering until **Phase A** exit criteria are met.

---

### Phase A — Minimum assets to start Chapter 4

**Exit criteria:** Core playtest has sound; desk has art decision; platform has acceptable parallax; Ch4 tension audio + platform SFX ready.

| Order | Asset | Method | Blocks |
|-------|-------|--------|--------|
| A1 | `ambient_desk.mp3` | Epidemic Sound | Silent desk — majority of game |
| A2 | `stamp.wav` | Epidemic Sound | Core desk feedback |
| A3 | `page_turn.wav` | Epidemic Sound | Document navigation feel |
| A4 | `ambient_platform.mp3` | Epidemic Sound | Silent platform |
| A5 | `ambient_menu.mp3` | Epidemic Sound | Menu first impression |
| A6 | **Desk background decision** | — | Choose: ship `bg_desk_office` **or** confirm `bg_terminal_wallpaper` as interim |
| A6a | `bg_desk_office` (if chosen) | ComfyUI | Production-quality desk |
| A7 | **Parallax decision** | — | Choose: procedural v1 OK for Ch4 start **or** batch PL-001–003 |
| A7a | `bg_city_far` | ComfyUI | If batching parallax |
| A7b | `bg_facility_mid` | ComfyUI | If batching parallax |
| A7c | `bg_facility_near` | ComfyUI | If batching parallax |
| A8 | `ambient_desk_tense.mp3` | Epidemic Sound | Ch4 chapter ambient |
| A9 | `sfx_emp_pulse.wav` | Epidemic Sound | EMP button already wired |
| A10 | `drone_alert.wav` | Epidemic Sound | Platform threat feedback |
| A11 | `sfx_scanner_flag.wav` | Epidemic Sound | Ch4 Ghost Audit scanner |
| A12 | `terminal_beep.wav` | Epidemic Sound | Platform terminal interact |
| A13 | `portrait_elias_venn` | ComfyUI | P0 — needed before Ch5; start if portrait batch running |
| A14 | `glitch_im_not_dead.wav` | Epidemic Sound + edit | C05 still in Ch1 — high narrative value |

**Phase A gate (from audit):** Session 1 audio ✓ · desk art decision ✓ · parallax decision ✓ · Ch4 tension/SFX ✓ → **approve Ch4 engineering**.

---

### Phase B — Global reusable assets

| Order | Asset | Method | Notes |
|-------|-------|--------|-------|
| B1 | `portrait_audit_voice` | ComfyUI | Lock if catalog QA fails style check |
| B2 | `portrait_jun_vale` | ComfyUI | Formal approval + dialogue wiring (content task) |
| B3 | `chapter_complete.mp3` | Epidemic Sound | Chapter transitions |
| B4 | `ambient_ending.mp3` | Epidemic Sound | Endings |
| B5 | `dead_letter_arrival.wav` | Epidemic Sound | Case queue atmosphere |
| B6 | `bg_chapter_complete` | ComfyUI | Post-chapter card |
| B7 | `mara_silhouette` | ComfyUI | Platform player polish |
| B8 | Parallax trio (if deferred from A) | ComfyUI | PL-001–003 complete batch |
| B9 | `AppIcon` | Manual | Store submission polish |

---

### Phase C — Chapter-specific assets

Produce before each chapter ships (not necessarily before Ch4 code starts).

| Chapter | Assets | Method | Ship gate |
|---------|--------|--------|-----------|
| **Ch3** (retroactive polish) | `bg_housing_mid`, `bg_housing_near` | ComfyUI | Level JSON already references these |
| **Ch4** | `ambient_desk_tense`, scanner/EMP SFX | Epidemic Sound | Phase A |
| **Ch5** | `portrait_elias_venn`, `bg_meridian_mid`, `ambient_meridian.mp3` | ComfyUI + ES | Before Ch5 playtest |
| **Ch6** | `bg_train_mid`, `ambient_platform_train.mp3`, `sfx_train_door.wav`, `glitch_orra_fragment.wav` | ComfyUI + ES | Before Ch6 playtest |
| **Ch7** | `ambient_choir.mp3`, `bg_undercity_mid` | ES + ComfyUI | Dialogue-heavy — portraits must be locked |
| **Ch8** | `ambient_desk_final.mp3`, `bg_central_archive_mid` | ES + ComfyUI | Desk climax C24; P08 infiltration only |

---

### Phase D — Final polish assets

Deferred until content complete or explicit polish pass. (P2+ in audit — listed for roadmap completeness.)

| Category | Assets | Method |
|----------|--------|--------|
| Sprites | `sprite_security_drone`, `sprite_security_guard` | ComfyUI |
| Stamp icons | `icon_stamp_approved` … `icon_stamp_flag` (×6) | ComfyUI or UI generated |
| Textures | `texture_document_paper` | ComfyUI |
| Pickups | `icon_pickup_data`, `icon_cartridge` | ComfyUI |
| Backgrounds | `bg_boot_screen`, `bg_ending_broadcast`, `bg_ending_control`, `bg_ending_erasure` | ComfyUI |
| Music | `ambient_boot.mp3` | Epidemic Sound |
| SFX | `data_cartridge_pickup.wav`, `door_unlock.wav` | Epidemic Sound |
| Splashes | `splash_ch1` … `splash_ch8` | ComfyUI |
| Optional | `bg_annex_mid` (Ch4 P2) | ComfyUI |

---

## Epidemic Sound session map (recommended batching)

| Session | Assets | Aligns with |
|---------|--------|-------------|
| **1** | `ambient_desk`, `ambient_menu`, `ambient_platform`, `stamp`, `page_turn` | Phase A |
| **2** | `chapter_complete`, `terminal_beep`, `drone_alert`, `sfx_emp_pulse` | Phase A–B |
| **3** | `ambient_desk_tense`, `glitch_im_not_dead`, `dead_letter_arrival`, `sfx_scanner_flag` | Phase A + Ch4 |
| **4** | `ambient_meridian`, `ambient_platform_train`, `sfx_train_door`, `glitch_orra_fragment` | Phase C Ch5–6 |
| **5** | `ambient_choir`, `ambient_desk_final`, `ambient_ending` | Phase C Ch7–8 |

---

## ComfyUI session map (recommended batching)

| Session | Assets | Aligns with |
|---------|--------|-------------|
| **1** | `portrait_elias_venn` (img2img from Mara) | Phase A |
| **2** | `bg_desk_office` OR QA `bg_terminal_wallpaper` | Phase A |
| **3** | `bg_city_far` + `bg_facility_mid` + `bg_facility_near` (shared seed family) | Phase A/B |
| **4** | `bg_housing_mid` + `bg_housing_near` | Phase C Ch3 |
| **5** | `mara_silhouette` | Phase B |
| **6** | `bg_chapter_complete` | Phase B |
| **7** | Chapter mid layers: meridian → train → undercity → central_archive | Phase C |

---

## Import checklist (every asset)

- [ ] Filename matches audit exactly (including `ambient_menu` not `ambient_mainmenu`)
- [ ] Post-processing pipeline completed per `docs/ArtStyleGuide.md`
- [ ] Silhouette test passed (visuals)
- [ ] Build and run — asset appears in correct scene
- [ ] Approved portraits copied to `assets/assets/Portraits/Approved/`
- [ ] Seed recorded in `docs/Art/ApprovedPortraitSettings.md`
- [ ] Phase 0.5 audit Ch4 gate items ticked

---

*Phase 0.6 approved 2026-06-05. Derived from Phase 0.5 Full Asset Audit, Art Style Guide v1.0, Asset Production Plan v4.0, Audio Production Plan v1.0, and CANON.md. Supersedes informal production notes where catalog state differs.*
