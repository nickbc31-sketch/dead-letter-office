# Dead Letter Office — Art Style Guide v1.0

**Authority document.** This guide supersedes all previous prompt lists, model recommendations, and art direction notes. When in doubt, refer to `Docs/refimg.png`.

**Last updated:** 2026-06-01

---

## Visual Authority

**Primary canon portrait:** `Docs/mararef.png` — the approved Mara Venn portrait. This is the single definitive visual standard for all character portraits. A detailed breakdown is in `Docs/STYLE_REFERENCE.md`. Study this image before generating any character portrait.

**Style comparison sheet:** `Docs/refimg.png` — shows the correct portrait style (left) versus the incorrect photorealistic style (right). Retained for context; superseded by `mararef.png` as the primary reference.

The correct style is visible in `mararef.png`. It is:
- Flat or near-flat shading with hard shadow edges
- Limited colour count (approximately 8–12 colours across the entire portrait)
- Simplified, readable facial features — not beautified or softened
- Hard-edged rim light, not a soft cinematic glow
- Solid dark background — no depth-of-field blur, no gradient
- The quality of a hand-painted game sprite at medium resolution

The incorrect style is the right-hand portrait in that image: photorealistic skin, soft subsurface scattering, detailed hair strands, bokeh background. This is what every photorealism model produces by default and it is wrong for this game.

---

## Core Identity

Dead Letter Office is a 1990s-style cinematic platformer and document thriller. Its art must feel like it was made in the early-to-mid 1990s for a high-end DOS or early CD-ROM platform — the era of *Flashback*, *Another World*, *Papers Please*, and *Beneath a Steel Sky*. Every asset should look like it belongs in the same faded, heavy, bureaucratic world.

**Single-sentence rule:** If the asset could appear in a 2023 mobile game, reject it.

---

## Visual Influences (in priority order)

1. **Papers, Please** (Lucas Pope, 2013) — Limited palette character portraits, strong flat shading, bureaucratic document aesthetic, zero ornamentation
2. **Flashback: The Quest for Identity** (Delphine Software, 1992) — Rotoscoped movement, dark silhouette environments, restrained colour
3. **Another World / Out of This World** (Éric Chahi, 1991) — Hard-edged silhouettes, pure shape, almost no surface detail, dramatic lighting from single source
4. **Beneath a Steel Sky** (Revolution Software, 1994) — Dystopian linework, dark urban atmosphere
5. **Syndicate** (Bullfrog, 1993) — Oppressive grey palette, bureaucratic violence, functional UI

---

## Colour Palette

These are the only colours permitted as dominant values in any game asset. Supporting tones (for shadows and highlights within a colour family) must stay within the same hue and low saturation.

| Role | Hex | Name |
|---|---|---|
| **Primary background** | `#070D14` | Deep navy |
| **Secondary background** | `#0D1420` | Terminal dark |
| **Mid shadow** | `#182030` | Slate |
| **UI border / mid grey** | `#405873` | Steel blue |
| **Dim text / dim shadow** | `#736B59` | Dusty khaki |
| **Teal accent** | `#00B5C9` | PMCA teal |
| **Amber accent** | `#FFB533` | Terminal amber |
| **Document cream** | `#DED7BD` | Aged paper |
| **Danger red** | `#D9261A` | Alert red |
| **Approve green** | `#6B4A28` | Ink dark (stamp border only) |
| **Near-black** | `#050810` | Void |

**Forbidden colours:** Purple, magenta, bright orange, neon green, pure white (`#FFFFFF`), pure black (`#000000`) as a dominant colour.

**Saturation rule:** No colour should exceed 60% saturation in Pixelmator's HSB model. If a generated image contains oversaturated colour, desaturate before import.

---

## Portrait Style

Portraits appear in DialogueScene at a displayed size of approximately 196 × 196 pts. They are overlaid with CRT scanlines. This means:
- Fine detail is destroyed by the scanline overlay — do not generate detail that will disappear
- Strong shape and strong colour contrast survive the CRT treatment — prioritise these
- Gradient skin tones become muddy through scanlines — use hard-edged flat tones instead

**Target quality:** Papers, Please character portrait. Hand-painted feel. Clearly a person, not a photograph of one.

**Correct attributes:**
- Flat or near-flat shading: 3–5 discrete skin tones, no blending between them
- Hard shadow edge on the darker side of the face — the terminator line is a visible edge, not a gradient
- Rim light from upper-left (teal `#00B5C9`), fill from right (amber `#FFB533`), both hard-edged
- Simplified facial features: readable at 196 × 196, not softened or beautified
- Solid dark navy background — `#070D14` — no depth, no haze, no gradient
- Dark government uniform occupying the lower half — very few folds, strong silhouette
- Total colour count for the full portrait: 8–12 distinct colours

**Incorrect attributes:**
- Photorealistic skin texture
- Subsurface scattering (the warm glow underneath skin)
- Soft bokeh background
- Detailed hair with individual strands
- Cinematic rim lighting with gradient falloff
- More than 16 distinct colours in the image

---

## Sprite Style

Player and enemy sprites operate at small sizes in the platform scene. The Mara sprite is displayed at approximately 24 × 52 points. The drone at approximately 32 × 24 points. At these sizes, pixel clarity is everything.

**Correct attributes:**
- True pixel art: discrete pixel grid, no anti-aliasing
- 4–6 colours maximum per sprite
- Solid dark silhouette forming the primary shape — the silhouette reads at a glance
- Single highlight colour for the lit edge
- Transparent background with hard pixel edges (no feathered transparency)
- Clear readable profile: left-facing or right-facing, unambiguous pose

**Resolution approach:**
- Generate at 256 × 512 (portrait) or 256 × 192 (drone) in DiffusionBee
- Immediately scale DOWN to the target sprite pixel dimensions in Pixelmator using nearest-neighbour scaling
- Scale back UP to 2x export size using nearest-neighbour only — never Lanczos on sprites
- This creates the authentic pixelated quality

---

## Background Style

Backgrounds appear in two contexts: full-screen scene backgrounds (DeskScene, MainMenuScene) and platform parallax layers. Both share the same core treatment.

**Full-screen backgrounds:**
- Dark dominant — primary background fills 60–80% of the image area
- 2–3 light sources maximum, both dim and atmospheric
- Flat or near-flat shading on all elements — no photorealistic materials
- Minimal detail in shadow areas — shadow is opaque dark colour, not detailed dark texture
- Total colour count: 12–16 colours maximum
- Should read clearly as a single environment type at a glance

**Platform parallax layers:**
- Far layer (scroll 0.1): Nearly pure silhouette. Sky is `#0D1420`, buildings are `#050810`. No interior detail. 2 colours.
- Mid layer (scroll 0.4): Some architectural form. 4–5 colours. Dark shadows with teal accent edge highlights.
- Near layer (scroll 0.7): Strongest contrast. Near-black foreground elements, transparent sky. 4–6 colours. Upper 50% transparent.

**All backgrounds must:**
- Never contain photorealistic materials (stone texture, metal sheen, fabric weave)
- Never contain rendered 3D lighting (specular highlights, ambient occlusion maps)
- Use hard edges between light and shadow areas, not gradients
- Contain no visible text, signage, or logos (the game UI renders text over backgrounds)

---

## UI Style

The UI (document cards, stamp buttons, tab controls, HUD) is rendered procedurally in code and does not require generated art for its primary elements. UI art assets (stamp icons, document paper texture) must match the terminal aesthetic.

**Stamp icons:**
- Black ink on transparent — the frame shape only, no interior fill colour
- Heavily worn/distressed ink edges (organic, not computer-perfect)
- No text, no letters — shape is the communication
- 2 colours maximum: near-black ink, transparent

**Document texture:**
- Aged warm paper (`#DED7BD` family) — not pure white, not bright
- Subtle grain and foxing — no visible print pattern, no lines, no ruled paper
- Must not obscure text rendered over it — keep opacity at 20–40% when used as overlay

**UI principle:** The PMCA terminal aesthetic is functional, not decorative. If an element does not communicate information, it should not exist.

---

## Contrast Rules

1. **Minimum contrast ratio:** Any text or interactive element against its background must have a contrast ratio of at least 4.5:1 (WCAG AA).
2. **Background luminance:** All background assets must have an average luminance below 30% when measured in Pixelmator's histogram.
3. **Highlight restriction:** No highlight colour should exceed 80% luminance. The brightest element in any scene is dim amber or teal.
4. **Shadow depth:** Shadow areas should reach near-black (`#050810`) or darker — shadows are not grey, they are near-black.
5. **Silhouette test:** Every asset must pass the silhouette test: convert to pure black on white. If the subject is unreadable, the asset has insufficient contrast and must be revised.

---

## Lighting Rules

1. **Two-light maximum** per scene and per portrait: one cool (teal), one warm (amber). No fill lights from below. No ambient environment light.
2. **Direction is fixed:** Rim light (teal `#00B5C9`) from upper-left. Fill light (amber `#FFB533`) from upper-right. This is consistent across all portraits and matches the Portrait Style section above.
3. **Hard terminator:** The edge between lit and shadow on a surface is a hard line, not a gradient. If your tool is producing a gradient, it is the wrong tool or the wrong settings.
4. **Shadow colour:** Shadows are not grey. In portraits and characters, shadow is a dark desaturated version of the character's base colour, pushed toward `#0D1420`. In environments, shadow is near-black.
5. **Ambient occlusion is forbidden:** AO produces the soft darkening in corners that is characteristic of 3D rendering. It should not appear in any asset.
6. **Specular highlights are forbidden on characters:** No shiny skin. No highlight dot on the eye. Portraits are flat.

---

## Character Proportions

- **Head:** Realistic adult — not anime (large eyes), not heroic fantasy (small head), not cartoonish (large chin). Papers, Please proportions: the head is a recognisable human head, not stylised.
- **Body:** Realistic adult proportions when visible. Simplified form — the body reads as shape, not musculature.
- **Facial features:** Simplified but recognisable. Mara has sharp cheekbones, a strong jaw, and tired eyes. Calyx has angular features and cold, pale eyes. These descriptions should be literal in the generation.
- **No beautification:** Generation models default to beautifying subjects (smoother skin, larger eyes, lifted features). Push back against this with explicit prompt terms and negative prompts.

---

## Animation Style

Platform scene animation is procedural (Swift code). No animation spritesheets are required for the vertical slice. If animated sprites are added later:
- 4–6 frames maximum per animation cycle
- Snap transitions (no tweening between frames)
- Each frame is a full pixel-art redraw, not a transformed version of the previous frame
- Walk cycle: 4 frames. Run: 6 frames. Jump: 2 frames (up / apex).

---

## Asset Resolution Strategy

| Asset type | Design points | @2x export pixels | DiffusionBee canvas | Final post-process to |
|---|---|---|---|---|
| Portrait | 196 × 196 | 392 × 392 | 1024 × 1024 | Resize to 392 × 392 |
| Full-screen background | 1334 × 750 | 2668 × 1500 | 1344 × 768 | Upscale to 2668 × 1500 |
| Platform strip (wide) | 3072 × 400 | 6144 × 800 | 1344 × 448 | Extend + upscale to 6144 × 800 |
| Player sprite | 64 × 96 | 128 × 192 | 512 × 768 | Scale DOWN (nearest-neighbour) to 128 × 192 |
| Drone sprite | 64 × 48 | 128 × 96 | 512 × 384 | Scale DOWN (nearest-neighbour) to 128 × 96 |
| Stamp icon | 64 × 64 | 128 × 128 | 512 × 512 | Scale DOWN to 128 × 128 |
| Pickup icon | 32 × 32 | 64 × 64 | 256 × 256 | Scale DOWN to 64 × 64 |
| Document texture | 256 × 384 | 512 × 768 | 1024 × 1024 | Crop to 512 × 768 |
| Chapter splash | 256 × 128 | 512 × 256 | 1024 × 512 | Resize to 512 × 256 |

**Nearest-neighbour scaling is mandatory for sprites.** Any other algorithm (Lanczos, bilinear) will introduce anti-aliasing fringing that breaks the pixel art look.

**Upscaling for backgrounds:** Lanczos is acceptable for background assets as they are not pixel art. RealESRGAN (available in some DiffusionBee versions) is better.

---

## Forbidden Styles

The following styles are explicitly prohibited. If a generated image resembles any of these, discard it.

### Photorealistic portraits
Skin with subsurface scattering, individual hair strands, catchlights in eyes, soft three-point studio lighting, depth-of-field background blur. This is what Juggernaut XL, Cyber Realistic, Epic Realism XL, and RealViz XL produce by default. Do not use these models for character portraits.

### AI glamour portraits
Beautified, symmetrical, smoothed-out subjects. The default output of most text-to-image models is a glamour portrait optimised for social media aesthetics. This is the opposite of what Dead Letter Office requires.

### Modern concept-art realism
High-detail rendered characters in the style of AAA game concept art or film VFX. Ambient occlusion, specular highlights, detailed material rendering, complex atmospheric backgrounds. This style has zero compatibility with this game.

### Anime / manga
Large eyes, simplified mouth, flowing hair, cel-shading in the anime tradition, Japanese character design proportions, any influence from anime aesthetic conventions.

### Western cartoon
Exaggerated proportions, strong black outlines, rubber-hose style, Disney or Pixar rendering quality, bright flat colours without shadow.

### Comic-book rendering
Heavy black ink outlines, Ben-Day dot halftone, exaggerated musculature, dynamic perspective lines, panel-composition staging.

### Hyper-detailed skin texture
Visible pores, stubble, skin imperfections rendered at photo quality, detailed eye anatomy. Even realistic-looking assets at this level of detail are wrong for this game.

### Smooth gradient shading
Any background or character that transitions smoothly from light to dark. All shading in this game uses hard edges or careful dithering — never smooth blending.

### Glossy rendering
Any surface that looks polished, wet, or plasticky. Matte surfaces only.

### Bright colours
Saturated primaries, neon tones, hues outside the game palette. If the image is colourful, it is wrong.

---

## DiffusionBee Generation Notes

None of the available models (Juggernaut XL, DreamShaper XL Turbo, Cyber Realistic, Epic Realism XL, RealViz XL) are native pixel-art models. The correct workflow is:

**Generate → Post-Process → Import**

The generation step produces a rough base. The post-processing step transforms it into the correct style. Do not import generation output directly.

**Recommended model by asset type:**

| Asset type | Model | Reason |
|---|---|---|
| Portraits | **DreamShaper XL Turbo** | More flexible with style prompts than photorealism models; lower CFG produces less photorealistic output |
| Full-screen backgrounds | **DreamShaper XL Turbo** | Same reason; stylized environments better than photographic |
| Platform parallax | **DreamShaper XL Turbo** | Silhouette/graphic style suits turbo model at low steps |
| Sprites | **DreamShaper XL Turbo** | Generate larger, post-process to pixel art |
| Stamps / UI | **DreamShaper XL Turbo** | Fast batches for icon work |
| Document texture | **DreamShaper XL Turbo** | Texture generation works well with turbo |
| Chapter splashes | **DreamShaper XL Turbo** | Stylized illustration fits turbo output |

**Juggernaut XL, Cyber Realistic, Epic Realism XL, RealViz XL:** Do not use for portraits. These models produce photorealistic output that is incompatible with the game's art direction. They may be used for background reference generation only if DreamShaper XL Turbo repeatedly fails, followed by heavy post-processing.

**DreamShaper XL Turbo settings for stylized art:**
- Steps: 8–12
- CFG: 2.0–3.5 (lower = more stylized, less photographic)
- Sampler: Euler or DPM++ SDE
- Batch: 6–8 (you need more batches because turbo output has more variance)

---

## Post-Processing Standard

Every generated asset must go through this process before import into Xcode.

### All assets
1. Export from DiffusionBee as PNG.
2. Open in Pixelmator (or GIMP).
3. **Colour reduction:** Effects → Stylize → Posterize. Set level to 6–8. This eliminates smooth gradients and forces colour into discrete bands.
4. **Palette correction:** Use Hue/Saturation adjustment to pull dominant colours toward the game palette (`#070D14`, `#00B5C9`, `#FFB533`). No asset should contain colours that are clearly outside the palette.
5. **Contrast boost:** Levels or Curves — push blacks toward true dark (`#050810`), pull highlights down to no brighter than 80% luminance.
6. **Silhouette test:** Flatten to black on white. Confirm the subject is readable at a glance. If not, increase contrast and retry.

### Portraits additionally
7. After posterization, manually check that skin tones are hard-edged, not gradients. If gradients remain after step 3, increase the posterize level.
8. Resize to 392 × 392 using Lanczos.

### Sprites additionally
7. After step 6, scale DOWN to target pixel dimensions (see Resolution Strategy table) using nearest-neighbour scaling.
8. Confirm no anti-aliased fringing on transparent edges. The pixel art should have hard, clean transparent cutouts.
9. Scale back up to @2x dimensions using nearest-neighbour only.

### Backgrounds additionally
7. After step 6, confirm average luminance is below 30% (check histogram).
8. Upscale to final dimensions using Lanczos or RealESRGAN.
9. For platform strips: extend canvas width by tiling and hand-blending seams in Pixelmator.

---

## Pre-Import Consistency Checklist

Before importing any asset into Xcode, confirm:

- [ ] Subject is readable as a silhouette (black on white test)
- [ ] Colour count is within the limit for the asset type
- [ ] No colour in the image exceeds 60% saturation
- [ ] No smooth gradients — all shading is hard-edged or dithered
- [ ] Asset uses colours from the game palette (teal, amber, dark navy, rust)
- [ ] No text, logos, or watermarks in the image
- [ ] Background is either transparent (portrait/sprite) or dark navy (environment)
- [ ] If portrait: style is consistent with the Mara Venn reference in `Docs/refimg.png`
- [ ] If sprite: scaled with nearest-neighbour, no fringing on transparent edges
- [ ] File is named exactly as specified in AssetProductionPlan.md
- [ ] Status updated to Approved in the asset checklist

---

*v1.0 — Visual authority established from `Docs/refimg.png`. All previous prompts are superseded.*
