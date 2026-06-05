# Dead Letter Office — Asset Production Plan v4.0

**Project:** Dead Letter Office (iOS SpriteKit)  
**Design canvas:** 1334 × 750 pts landscape (@2x export = 2668 × 1500 px for full-screen assets)  
**Export standard:** PNG; portrait and sprite assets require transparent background  
**Last updated:** 2026-06-01  
**Scope:** Vertical slice — Chapter 1 only  
**Art authority:** `docs/art/PortraitStyleReference.md` (portraits), `Docs/ArtStyleGuide.md` (all assets)

> **v4.0 note:** Four character portraits are now approved canon. Portrait prompts and settings updated to reflect the approved visual standard. Portrait style reference is now `docs/art/PortraitStyleReference.md` — consult it before generating any character portrait. Approved files live at `assets/assets/Portraits/Approved/`. New generated portraits go to `assets/assets/Portraits/generated/` for review before approval.

> **v3.0 note:** All prompts rewritten from v2.0. Previous prompts targeted photorealism (Juggernaut XL).

---

## Approved Portraits — Canon Reference

These portraits are locked. Do not regenerate.

| Character | Approved file | Approval date |
|---|---|---|
| Mara Venn | `assets/assets/Portraits/Approved/mara_venn_v1_approved.png` | 2026-06-01 |
| Director Calyx | `assets/assets/Portraits/Approved/calyx_v1_approved.png` | 2026-06-01 |
| Saint Orra | `assets/assets/Portraits/Approved/saint_orra_v1_approved.png` | 2026-06-01 |
| PMCA Director | `assets/assets/Portraits/Approved/pmca_director_v1_approved.png` | 2026-06-01 |

Record seeds and generation settings in `docs/art/ApprovedPortraitSettings.md`.

---

## Global Style Lock

Every visual prompt **must** include this phrase verbatim. Copy and paste it into every generation.

```
DEAD LETTER OFFICE STYLE, flat shading, limited colour palette, pixel art adjacent, hard edge shadows, no gradients, posterized, retro dystopian bureaucratic game art, Papers Please character art style, 1990s PC game aesthetic, strong silhouettes, teal and amber accents on dark navy, no photorealism, no smooth 3D rendering, no soft lighting, no text, no logos
```

**Palette lock:** All assets must use colours from this set. If a generated image introduces a colour outside this set, correct it in post-processing before import.

| Slot | Hex | Use |
|---|---|---|
| Primary background | `#070D14` | Sky, void, scene base |
| Terminal dark | `#0D1420` | Secondary backgrounds, shadow |
| Slate | `#182030` | Deep mid-shadow |
| Steel blue | `#405873` | UI borders, mid elements |
| Teal | `#00B5C9` | Accent light, terminal colour |
| Amber | `#FFB533` | Accent light, UI, warm highlights |
| Aged paper | `#DED7BD` | Document surfaces |
| Danger red | `#D9261A` | Alerts, stamps |
| Near-black | `#050810` | Deepest shadow, silhouette |

---

## Model Selection

| Role | Model | Reason |
|---|---|---|
| **Primary — all assets** | **DreamShaper XL Turbo** | Most flexible model for non-photorealistic output. At low CFG (2–3), produces stylized, graphic results that post-process well into the correct game style. |
| **Background fallback only** | Juggernaut XL | Use only for environments if DreamShaper XL Turbo produces incoherent results after 3 batches. Never use for portraits or sprites. Requires very heavy post-processing. |
| **Do not use for any asset** | Cyber Realistic, Epic Realism XL, RealViz XL | These models produce photorealistic output that is incompatible with this game's art direction. |

**Portrait rule:** All portraits must be generated with the same model at the same base settings. Once Mara Venn's portrait is approved, do not change model or major settings for any other portrait.

---

## Recommended DiffusionBee Defaults

Read `Docs/ArtStyleGuide.md` for the full post-processing workflow that must follow every generation step.

### Portraits

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 1024 × 1024 |
| Sampler | Euler |
| Steps | 10 |
| CFG / Guidance | 2.5 |
| Seed policy | Random first 2 batches; lock seed once a good composition appears |
| Batch count | 8 (turbo output has more variance; you need more to find the best) |
| Img2Img | No |
| Post-processing | Posterize (level 7) → palette correct → contrast boost → resize to 392 × 392 |

### Scene Backgrounds (full screen)

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 1344 × 768 |
| Sampler | Euler |
| Steps | 10 |
| CFG / Guidance | 3.0 |
| Seed policy | Random; lock after good composition |
| Batch count | 6 |
| Img2Img | No |
| Post-processing | Posterize (level 8) → palette correct → contrast boost → upscale to 2668 × 1500 |

### Platform Parallax Layers (wide strips)

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 1344 × 448 |
| Sampler | Euler |
| Steps | 10 |
| CFG / Guidance | 2.5 |
| Seed policy | Lock seed once silhouette composition is clean; use same seed for tile extensions |
| Batch count | 6 |
| Img2Img | Yes — 0.40 strength when extending tiles |
| Post-processing | Posterize → palette correct → extend canvas in Pixelmator → upscale height to 800 px |

### Character / Player Sprites

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 512 × 768 |
| Sampler | Euler |
| Steps | 10 |
| CFG / Guidance | 2.5 |
| Seed policy | Random; lock once clean silhouette found |
| Batch count | 10 |
| Img2Img | No |
| Post-processing | Remove background → posterize (level 5) → scale DOWN to pixel dimensions (nearest-neighbour) → scale back to @2x (nearest-neighbour) |

### UI Icons / Stamps

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 512 × 512 |
| Sampler | Euler |
| Steps | 8 |
| CFG / Guidance | 2.5 |
| Seed policy | Random |
| Batch count | 12 (stamps need distressed variation) |
| Img2Img | No |
| Post-processing | Remove background → reduce to 2–3 colours → check against game palette |

### Document / Paper Textures

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 1024 × 1024 |
| Sampler | Euler |
| Steps | 8 |
| CFG / Guidance | 2.0 |
| Seed policy | Random |
| Batch count | 4 |
| Img2Img | No |
| Post-processing | Desaturate toward aged paper tone → reduce opacity → confirm text remains readable over it |

### Chapter Splash Screens

| Setting | Value |
|---|---|
| Model | DreamShaper XL Turbo |
| Canvas size | 1024 × 512 |
| Sampler | Euler |
| Steps | 10 |
| CFG / Guidance | 3.0 |
| Seed policy | Different seed per chapter |
| Batch count | 6 |
| Img2Img | No |
| Post-processing | Posterize → palette correct → resize to 512 × 256 |

---

## Generation Workflow For Nick

1. Open **DiffusionBee**.
2. Select **DreamShaper XL Turbo** (primary model for all assets).
3. Set canvas dimensions from the asset entry below.
4. Paste the **Prompt** from the asset entry. Confirm it contains the Global Style Lock phrase.
5. Paste the **Negative Prompt** from the asset entry.
6. Set Sampler, Steps, and CFG as specified in the Defaults tables above.
7. Set seed to -1 (random) for the first two batches.
8. Generate. Review batch. Select the best composition.
9. If all results are photorealistic or incorrect style: lower CFG to 2.0 and regenerate. If still wrong after 3 batches, switch to Euler a sampler.
10. Export best result as PNG using the exact filename from the asset entry.
11. Open in **Pixelmator**. Apply the Post-Processing Standard from `Docs/ArtStyleGuide.md`.
12. Run the silhouette test: flatten to black on white. Subject must be readable. If not, increase contrast and retry step 11.
13. In **Xcode**: navigate to `Assets.xcassets`, create or open the correct `.imageset`, drag in the post-processed PNG, confirm the 2x slot is populated.
14. **Build and run** to verify the asset appears correctly in the scene.
15. Mark status in this document as **Approved**. Record the seed if the result was exceptional.

---

## Consistency Rules

- Use DreamShaper XL Turbo for all assets. Do not mix models for portraits.
- Apply identical CFG (2.5) and Steps (10) for all portraits so they share a rendering baseline.
- Lock Mara Venn's seed and record it here once her portrait is approved: **[SEED NOT YET SET]**
- Do not import any asset that has not been through the Posterize step. Smooth shading is not acceptable.
- Do not allow text or logos in any AI-generated image. If they appear, regenerate or paint them out.
- Confirm every asset passes the silhouette test (readable as black on white) before import.
- All character portraits must share the same lighting direction: teal from upper-left, amber from upper-right.
- Platform parallax layers must be generated in a single session with the same seed family so they look like they belong in the same environment.

---

## Priority Tiers

| Tier | Meaning |
|---|---|
| **T1** | Required for Chapter 1 vertical slice to feel finished |
| **T2** | Important polish; Chapter 1 runs without these |
| **T3** | Deferred until vertical slice milestone is complete |

---

## Generation Status

### Approved portraits (do not regenerate)

| Asset ID | Name | Approved file |
|---|---|---|
| P-001 | portrait_mara | `mara_venn_v1_approved.png` ✓ |
| P-003 | portrait_calyx | `calyx_v1_approved.png` ✓ |
| P-005 | portrait_saint_orra | `saint_orra_v1_approved.png` ✓ |
| P-007 | portrait_pmca_director | `pmca_director_v1_approved.png` ✓ |

### Next portrait priority

Generate these in order. Use `docs/art/PortraitStyleReference.md` as the generation reference.

| Order | Asset ID | Name | Reason |
|---|---|---|---|
| 1 | P-004 | portrait_jun_vale | Key Ch1 character — civilian/resistance clothing, style consistency test |
| 2 | P-002 | portrait_audit_voice | Unique non-human challenge — no face |
| 3 | P-006 | portrait_elias_venn | Sibling resemblance test — use Mara as img2img base |

### Remaining first-pass batch (backgrounds + sprite)

Complete portrait approvals above before starting these.

| Order | Asset ID | Name | Reason |
|---|---|---|---|
| 4 | BG-001 | bg_desk_office | Visible throughout gameplay |
| 5 | PL-001 | bg_city_far | Platform level far layer |
| 6 | PL-002 | bg_facility_mid | Platform level mid layer |
| 7 | CH-001 | mara_silhouette | Player sprite |

---

## Shared Negative Prompt

Paste this into every generation in addition to the asset-specific negative prompt.

```
photorealistic, hyperrealistic, glamour portrait, beauty portrait, instagram portrait, subsurface scattering, soft skin, detailed pores, realistic hair strands, bokeh, depth of field, soft lighting, cinematic lighting, ambient occlusion, specular highlights, smooth gradients, 8k, high resolution photography, studio lighting, realistic textures, 3d render, vray, octane render, anime, manga, cartoon, comic book, western animation, cel shading anime style, glossy, smooth shading, bright saturated colours, neon, purple, magenta, deformed, extra limbs, bad anatomy, watermark, signature, text, logo
```

---

## Asset Entries

> In all prompts below, `[GSL]` means the full Global Style Lock phrase. Replace it before pasting into DiffusionBee.

---

### P-001 — portrait_mara

| Field | Value |
|---|---|
| **Asset ID** | P-001 |
| **Asset name** | Mara Venn — clerk protagonist |
| **Priority** | T1 |
| **Purpose** | DialogueScene portrait. Displayed at 196 × 196 pts behind CRT scanlines. |
| **Required filename** | `portrait_mara@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_mara.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — solid dark background or true transparent |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo with CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random first 2 batches; lock once approved. Record seed: **[NOT YET SET]** |
| **Batch count** | 8 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | **Approved** — `mara_venn_v1_approved.png` |

> **Approved portrait is canon.** Do not regenerate. Reference `docs/art/PortraitStyleReference.md` and `assets/assets/Portraits/Approved/mara_venn_v1_approved.png` for style matching. Record seed in `docs/art/ApprovedPortraitSettings.md`.

**Prompt (for reference / future revision only):**
```
East Asian woman late twenties, three-quarter view, black hair pulled back in updo flat simplified shape, tired intelligent eyes, controlled neutral expression, slight jaw tension, dark steel-blue PMCA government clerk uniform high collar, two small gold collar pins, solid medium blue-grey background, DEAD LETTER OFFICE STYLE, flat colour illustration, limited colour palette, hard-edge shadow planes, discrete tonal bands, no gradient blending, matte surfaces, bust composition, [GSL]
```

**Asset-specific negative prompt:**
```
long hair, flowing hair, detailed hair strands, soft skin glow, smile, happy, exaggerated eyes, anime eyes, makeup, lipstick, jewellery, gradient background, vignette background, dark background, black background, catchlights, eye highlights
```

**Post-processing:** Posterize level 7 → palette correct toward approved portrait values → resize to 392 × 392 Lanczos → review against `mara_venn_v1_approved.png`.

**Xcode integration:** `portrait_mara.imageset`, 2x slot.

---

### P-002 — portrait_audit_voice

| Field | Value |
|---|---|
| **Asset ID** | P-002 |
| **Asset name** | The Audit Voice — abstract surveillance entity |
| **Priority** | T1 |
| **Purpose** | DialogueScene portrait for every Audit Voice line. |
| **Required filename** | `portrait_audit_voice@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_audit_voice.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | No — solid black background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random |
| **Batch count** | 10 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
geometric abstract surveillance mask, completely smooth featureless dark obsidian surface, single narrow horizontal amber glowing slit where eyes would be, faint teal circuit pattern barely visible at edges, floating in absolute black void, no mouth no nose no ears no hair no body, [GSL], flat graphic design, 5-colour palette maximum, strong geometric silhouette, cold bureaucratic presence, square composition centred
```

**Asset-specific negative prompt:**
```
human face, skull, robot face, mechanical parts, eyes, mouth, teeth, body, hands, hair, background detail, complex shapes, multiple objects
```

**Post-processing:** Posterize level 5 → background must be pure black `#050810` → amber slit should be `#FFB533`.

**Xcode integration:** `portrait_audit_voice.imageset`, 2x slot.

---

### P-003 — portrait_calyx

| Field | Value |
|---|---|
| **Asset ID** | P-003 |
| **Asset name** | Director Calyx — antagonist |
| **Priority** | T1 |
| **Purpose** | DialogueScene portrait. First human antagonist. |
| **Required filename** | `portrait_calyx@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_calyx.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — medium blue-grey background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Match Mara's CFG for consistent style |
| **Batch count** | 8 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | **Approved** — `calyx_v1_approved.png` |

> **Approved portrait is canon. Visual design has been finalised.** The previously documented description (middle-aged man, grey slicked-back hair) is superseded by the approved portrait. Calyx is now: East Asian man, black hair, late thirties to early forties, dark civilian authority suit and tie, intense direct gaze, near-frontal view. Do not regenerate. Record seed in `docs/art/ApprovedPortraitSettings.md`.

**Prompt (updated to match approved portrait — for reference / revision only):**
```
East Asian man late thirties, near-frontal portrait, black short hair, intense controlled direct gaze, dark near-black civilian authority suit, dark tie, hard-edged facial shadow planes, dramatic cheekbone and brow shadow, solid medium blue-grey background, DEAD LETTER OFFICE STYLE, flat colour illustration, limited colour palette, hard-edge shadow planes, discrete tonal bands, no gradient blending, matte surfaces, bust composition, [GSL]
```

**Asset-specific negative prompt:**
```
friendly expression, smile, warm lighting, soft features, beard, grey hair, government uniform, colourful background, gradient background, dark background, black background, catchlights, eye highlights, young teenager
```

**Post-processing:** Same pipeline as P-001. Review against `calyx_v1_approved.png` — note more dramatic shadow contrast than Mara.

**Xcode integration:** `portrait_calyx.imageset`, 2x slot.

---

### P-004 — portrait_jun_vale

| Field | Value |
|---|---|
| **Asset ID** | P-004 |
| **Asset name** | Jun Vale — alive but officially dead |
| **Priority** | T1 |
| **Purpose** | DialogueScene portrait. Key resistance contact in Ch1. |
| **Required filename** | `portrait_jun_vale@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_jun_vale.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — dark background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random; match lighting to other portraits |
| **Batch count** | 8 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
Southeast Asian man mid-thirties, near-frontal portrait, cropped dark hair, sharp watchful eyes, small scar on chin, worn dark civilian jacket over collared layer, guarded wary expression with underlying urgency, resistance underground aesthetic, solid medium blue-grey background, DEAD LETTER OFFICE STYLE, flat colour illustration, limited colour palette, hard-edge shadow planes, discrete tonal bands, no gradient blending, matte surfaces, bust composition, [GSL]
```

**Asset-specific negative prompt:**
```
weapons visible, combat gear, cheerful expression, government uniform, soft background, gradient, long hair
```

**Post-processing:** Same pipeline as P-001.

**Xcode integration:** `portrait_jun_vale.imageset`, 2x slot.

---

### P-005 — portrait_saint_orra

| Field | Value |
|---|---|
| **Asset ID** | P-005 |
| **Asset name** | Saint Orra — officially erased resistance figure |
| **Priority** | T2 |
| **Purpose** | DialogueScene portrait. Mid-to-late Ch1 and later chapters. |
| **Required filename** | `portrait_saint_orra@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_saint_orra.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — medium blue-grey background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random; match lighting |
| **Batch count** | 8 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | **Approved** — `saint_orra_v1_approved.png` |

> **Approved portrait is canon.** Do not regenerate. Record seed in `docs/art/ApprovedPortraitSettings.md`.

**Prompt:**
```
flat shading portrait, woman in her forties, natural dark hair worn loose, deep brown eyes with calm absolute certainty, faint scarring on neck, plain dark worn clothing suggesting years in hiding, expression of fierce quiet conviction, the face of someone who has decided, hard teal rim from upper left, hard amber from upper right, solid near-black background #070D14, [GSL], 8-colour limited palette, Papers Please character portrait quality, consistent lighting with other portraits
```

**Asset-specific negative prompt:**
```
halo, wings, supernatural glow, saintly imagery, religious symbols, cheerful, soft, young, gradient background
```

**Post-processing:** Same pipeline as P-001.

**Xcode integration:** `portrait_saint_orra.imageset`, 2x slot.

---

### P-006 — portrait_elias_venn

| Field | Value |
|---|---|
| **Asset ID** | P-006 |
| **Asset name** | Elias Venn — Mara's missing brother |
| **Priority** | T2 |
| **Purpose** | DialogueScene portrait. Appears in later Ch1 reveals. |
| **Required filename** | `portrait_elias_venn@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_elias_venn.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — very dark, near-transparent background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Generate after Mara approved; use same base settings |
| **Batch count** | 8 |
| **Img2Img** | Yes — use portrait_mara as input at 0.20 strength for sibling resemblance |
| **Img2Img strength** | 0.20 |
| **Status** | Missing |

**Prompt:**
```
flat shading portrait, young East Asian man mid-twenties, similar angular features to his sister, short dark hair, intelligent eyes carrying fear and confusion, plain dark collar shirt, slightly desaturated skin tones suggesting a digital transmission artifact, ghostly quality to the image, hard faint teal rim from upper left, very dark near-black background almost blending with figure, [GSL], 8-colour limited palette, Papers Please character portrait quality
```

**Asset-specific negative prompt:**
```
zombie, horror, gore, solid fully-opaque appearance, cheerful, colourful background, young girl, female
```

**Post-processing:** After posterize, reduce overall opacity of the figure to approximately 85% in Pixelmator to give ghostly quality. Background must be near-pure black.

**Xcode integration:** `portrait_elias_venn.imageset`, 2x slot.

---

### P-007 — portrait_pmca_director

| Field | Value |
|---|---|
| **Asset ID** | P-007 |
| **Asset name** | PMCA Director — senior authority figure |
| **Priority** | T1 |
| **Purpose** | DialogueScene portrait. Senior PMCA official. |
| **Required filename** | `portrait_pmca_director@2x.png` |
| **Destination folder** | `Assets.xcassets/Portraits/portrait_pmca_director.imageset/` |
| **Required dimensions** | 392 × 392 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes — medium blue-grey background |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | DreamShaper XL Turbo at CFG 2.0 |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Match other portrait settings |
| **Batch count** | 8 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | **Approved** — `pmca_director_v1_approved.png` |

> **Approved portrait is canon.** Do not regenerate. Record seed in `docs/art/ApprovedPortraitSettings.md`. The PMCA Director is distinct from Director Calyx — older man, grey hair, mustache, heavyset authoritative bearing.

**Prompt (for reference / revision only):**
```
older man late fifties, near-frontal portrait, grey hair combed to side, grey mustache, heavy authoritative face with jowl definition, controlled official expression, dark near-black civilian authority suit, dark tie, solid medium blue-grey background, DEAD LETTER OFFICE STYLE, flat colour illustration, limited colour palette, hard-edge shadow planes, discrete tonal bands, no gradient blending, matte surfaces, bust composition, [GSL]
```

**Asset-specific negative prompt:**
```
young, black hair, beard, military uniform, friendly expression, smile, warm lighting, gradient background, dark background, black background, catchlights, eye highlights
```

**Post-processing:** Same pipeline as P-001. Most tonal complexity of the approved portraits — preserve the face structure shadow planes during posterize.

**Xcode integration:** `portrait_pmca_director.imageset`, 2x slot.

---

### BG-001 — bg_desk_office

| Field | Value |
|---|---|
| **Asset ID** | BG-001 |
| **Asset name** | PMCA Clerk Desk — primary gameplay background |
| **Priority** | T1 |
| **Purpose** | Optional backdrop for DeskScene. Currently procedural; this replaces the placeholder. |
| **Required filename** | `bg_desk_office@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_desk_office.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | Juggernaut XL + heavy post-processing |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Seed policy** | Random; lock once good composition found |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
retro game environment background, institutional clerk desk from slight overhead angle, dark worn wooden surface, worn leather desk blotter, heavy CRT terminal with amber phosphor glow, single amber desk lamp cone of light, wire inbox tray, dark filing shelf wall in background, [GSL], limited 12-colour palette, flat graphic shading, 1990s PC game background art, Flashback game aesthetic, no people, wide landscape composition, dark left third for title overlay
```

**Asset-specific negative prompt:**
```
photorealistic wood grain, realistic material rendering, detailed textures, modern office furniture, clean surfaces, people visible, computer screens with content
```

**Post-processing:** Posterize level 8 → palette correct → confirm average luminance below 30% → upscale to 2668 × 1500.

**Xcode integration:** `bg_desk_office.imageset`, 2x slot.

---

### BG-002 — bg_main_menu

| Field | Value |
|---|---|
| **Asset ID** | BG-002 |
| **Asset name** | PMCA Archive — main menu background |
| **Priority** | T1 |
| **Purpose** | Optional atmospheric backdrop for MainMenuScene. Currently procedural rain. |
| **Required filename** | `bg_main_menu@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_main_menu.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | Juggernaut XL + heavy post-processing |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Seed policy** | Random |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
retro game environment background, vast brutalist government archive interior at night, rows of identical dark filing cabinets receding to vanishing point, single amber overhead lamp cone on empty desk in foreground, tall narrow window far background showing teal-lit dark city skyline, heavy atmospheric dark, [GSL], limited 10-colour palette, flat graphic shading, 1990s PC game environment art, Papers Please office aesthetic, left third darkest for menu title, no people
```

**Asset-specific negative prompt:**
```
cluttered foreground, bright windows, modern furniture, photorealistic materials, gradient sky
```

**Post-processing:** Posterize level 8 → ensure left third average luminance below 20% → upscale to 2668 × 1500.

**Xcode integration:** `bg_main_menu.imageset`, 2x slot.

---

### BG-003 — bg_chapter_complete

| Field | Value |
|---|---|
| **Asset ID** | BG-003 |
| **Asset name** | Night window — chapter transition |
| **Priority** | T2 |
| **Purpose** | ChapterCompleteScene background. Currently black. |
| **Required filename** | `bg_chapter_complete@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_chapter_complete.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Fallback model** | Juggernaut XL + heavy post-processing |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Seed policy** | Random |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
retro game background, looking through tall narrow institutional window at night, dark rain-soaked dystopian city below, amber street lights and teal transmission towers in fog, dark institutional concrete window frame interior, reflection of desk lamp in glass, melancholic quiet atmosphere, [GSL], limited 10-colour palette, flat graphic shading, 1990s PC game environment, wide landscape format, centre darker for text overlay, no people
```

**Asset-specific negative prompt:**
```
bright city lights, neon signs, photorealistic glass reflection, clear sky, cheerful mood
```

**Post-processing:** Posterize level 8 → upscale to 2668 × 1500.

**Xcode integration:** `bg_chapter_complete.imageset`, 2x slot.

---

### BG-004 — bg_ending_broadcast

| Field | Value |
|---|---|
| **Asset ID** | BG-004 |
| **Asset name** | Underground broadcast station — Ending A |
| **Priority** | T3 |
| **Required filename** | `bg_ending_broadcast@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_ending_broadcast.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
retro game background, vast underground pirate broadcasting station in converted maintenance tunnel, rows of analogue radio transmitters and antenna arrays, amber and teal lighting, two or three silhouetted human figures at distance before screens, hopeful but tense atmosphere, industrial cables everywhere, [GSL], limited 10-colour palette, flat graphic shading, 1990s PC game environment, landscape composition
```

**Asset-specific negative prompt:**
```
modern broadcast equipment, photorealistic, detailed faces, bright colours
```

**Post-processing:** Posterize → upscale to 2668 × 1500.

**Xcode integration:** `bg_ending_broadcast.imageset`, 2x slot.

---

### BG-005 — bg_ending_control

| Field | Value |
|---|---|
| **Asset ID** | BG-005 |
| **Asset name** | Government surveillance command — Ending B |
| **Priority** | T3 |
| **Required filename** | `bg_ending_control@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_ending_control.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
retro game background, towering brutalist government surveillance command room, multiple levels of dark terminals, silhouetted operators at distance, giant screens covering walls showing abstract data displays in amber and teal, oppressive monumental scale, architecture of institutional control, [GSL], limited 10-colour palette, flat graphic shading, 1990s PC game environment, landscape composition
```

**Post-processing:** Posterize → upscale to 2668 × 1500.

**Xcode integration:** `bg_ending_control.imageset`, 2x slot.

---

### BG-006 — bg_ending_erasure

| Field | Value |
|---|---|
| **Asset ID** | BG-006 |
| **Asset name** | Empty archive — Ending C |
| **Priority** | T3 |
| **Required filename** | `bg_ending_erasure@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_ending_erasure.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Batch count** | 6 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
retro game background, empty dark archive room in brutalist facility, all shelves completely bare, filing cabinets open and emptied, scattered papers on floor under single amber lamp, profound absence and deliberate erasure, faint teal light from half-open doorway, [GSL], limited 10-colour palette, flat graphic shading, 1990s PC game environment, landscape composition, no people
```

**Post-processing:** Posterize → upscale to 2668 × 1500.

**Xcode integration:** `bg_ending_erasure.imageset`, 2x slot.

---

### BG-007 — bg_boot_screen

| Field | Value |
|---|---|
| **Asset ID** | BG-007 |
| **Asset name** | Government terminal boot texture |
| **Priority** | T3 |
| **Required filename** | `bg_boot_screen@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_boot_screen.imageset/` |
| **Required dimensions** | 2668 × 1500 px |
| **Aspect ratio** | 16:9 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 8 |
| **CFG** | 2.0 |
| **Batch count** | 4 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
abstract dark texture, near-black surface, faint teal circuit trace pattern barely visible, amber light catching intersections, extreme low contrast, government terminal loading screen, [GSL], 4-colour maximum palette, flat graphic, purely abstract
```

**Post-processing:** Posterize level 4 → reduce brightness to near-black → upscale to 2668 × 1500.

**Xcode integration:** `bg_boot_screen.imageset`, 2x slot.

---

### PL-001 — bg_city_far

| Field | Value |
|---|---|
| **Asset ID** | PL-001 |
| **Asset name** | Distant megacity skyline — far parallax layer |
| **Priority** | T1 |
| **Purpose** | Platform level background, far layer (scroll factor ~0.1). |
| **Required filename** | `bg_city_far@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_city_far.imageset/` |
| **Required dimensions** | 6144 × 800 px |
| **Aspect ratio** | ~7.68:1 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Lock seed after good base found; use same seed for tile extensions |
| **Batch count** | 6 |
| **Img2Img** | Yes — 0.40 strength for seamless tile extensions |
| **Img2Img strength** | 0.40 |
| **Status** | Missing |

**Prompt:**
```
pixel art game background layer, far city skyline silhouette strip, vast dystopian megacity at night seen from below, jagged skyscraper silhouettes against very slightly lighter dark teal-navy sky, sparse amber pinprick lights in building faces, heavy smog, [GSL], 3-colour palette maximum (near-black buildings, dark navy sky, amber pinpoints), flat graphic silhouette style, Another World 1991 game aesthetic, ultra-wide panoramic strip format, no foreground elements, low horizon line
```

**Asset-specific negative prompt:**
```
detailed buildings, windows with detail, people, vehicles, foreground objects, more than 4 colours, gradient sky, clouds
```

**Post-processing:** Posterize level 4 → restrict to exactly 3 colours (near-black `#050810`, dark navy `#0D1420`, amber `#FFB533`) → extend canvas to 6144 px wide → upscale height to 800 px.

**Xcode integration:** `bg_city_far.imageset`, 2x slot.

---

### PL-002 — bg_facility_mid

| Field | Value |
|---|---|
| **Asset ID** | PL-002 |
| **Asset name** | Industrial sorting facility — mid parallax layer |
| **Priority** | T1 |
| **Purpose** | Platform level mid layer (scroll factor ~0.4). |
| **Required filename** | `bg_facility_mid@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_facility_mid.imageset/` |
| **Required dimensions** | 6144 × 800 px |
| **Aspect ratio** | ~7.68:1 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Use same seed family as PL-001 for environmental coherence |
| **Batch count** | 6 |
| **Img2Img** | Yes — 0.40 strength for tiling |
| **Img2Img strength** | 0.40 |
| **Status** | Missing |

**Prompt:**
```
pixel art game background layer, industrial sorting facility mid-ground, dark mechanical conveyor structures and sorting racks receding into shadow, amber emergency lighting strips on ceiling, teal-lit cable trays overhead, deep atmospheric dark, brutalist concrete columns, [GSL], 6-colour palette, flat graphic shading, Another World 1991 game aesthetic, ultra-wide panoramic strip, no sky visible, industrial ceiling only, no people
```

**Asset-specific negative prompt:**
```
photorealistic machinery, detailed textures, bright colours, sky, clouds, people, modern clean equipment
```

**Post-processing:** Posterize level 6 → restrict palette to game colours → extend to 6144 px wide → upscale height to 800 px. Must visually belong in same environment as PL-001.

**Xcode integration:** `bg_facility_mid.imageset`, 2x slot.

---

### PL-003 — bg_facility_near

| Field | Value |
|---|---|
| **Asset ID** | PL-003 |
| **Asset name** | Near-ground pipes — near parallax layer |
| **Priority** | T1 |
| **Purpose** | Platform level near layer (scroll factor ~0.7). Upper 50% must be transparent. |
| **Required filename** | `bg_facility_near@2x.png` |
| **Destination folder** | `Assets.xcassets/Backgrounds/bg_facility_near.imageset/` |
| **Required dimensions** | 6144 × 800 px |
| **Aspect ratio** | ~7.68:1 |
| **Transparency** | **Yes — upper 50% fully transparent** |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Same seed family as PL-001 and PL-002 |
| **Batch count** | 6 |
| **Img2Img** | Yes — 0.40 strength for tiling |
| **Img2Img strength** | 0.40 |
| **Status** | Missing |

**Prompt:**
```
pixel art game foreground layer, bottom half only, large dark corroded metal pipes and cable conduits running horizontally, worn metal floor plates, amber indicator lights on wall panels, deep shadow pools, [GSL], 5-colour palette, flat graphic silhouettes, Another World 1991 game aesthetic, content in BOTTOM HALF ONLY, top half is empty space, ultra-wide panoramic strip, no people
```

**Asset-specific negative prompt:**
```
sky, upper half content, people, vehicles, bright colours, photorealistic materials, gradient
```

**Post-processing:** After posterize: select upper 50% of image → delete (fill with full transparency) → apply gradient from solid at bottom-50% to transparent at 55% height → extend to 6144 px → export with alpha channel.

**Xcode integration:** `bg_facility_near.imageset`, 2x slot. Must be PNG with alpha.

---

### CH-001 — mara_silhouette

| Field | Value |
|---|---|
| **Asset ID** | CH-001 |
| **Asset name** | Mara Venn — player sprite, side view |
| **Priority** | T1 |
| **Purpose** | MaraPlayerNode in PlatformScene. Currently procedural. |
| **Required filename** | `mara_silhouette@2x.png` |
| **Destination folder** | `Assets.xcassets/Characters/mara_silhouette.imageset/` |
| **Required dimensions** | 128 × 192 px |
| **Aspect ratio** | 2:3 |
| **Transparency** | Yes |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random; select cleanest pixel silhouette |
| **Batch count** | 12 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
pixel art game sprite, full body standing side view, slim young woman in fitted government clerk uniform, slight action-ready lean, completely flat near-black teal silhouette body, single amber rim light on right edge only, no internal detail, clean pixel edges, [GSL], 4-colour palette maximum, transparent background, portrait orientation, Flashback 1992 game character sprite, Another World player character aesthetic, 1990s side-scroller proportions
```

**Asset-specific negative prompt:**
```
detailed face, internal clothing detail, white background, loose pose, weapons, multiple characters, background elements, more than 4 colours
```

**Post-processing:** Remove background (Instant Alpha in Preview, or Fuzzy Select in GIMP) → posterize level 4 → **scale DOWN to 128 × 192 using nearest-neighbour only** → verify hard pixel edges with no fringing → no Lanczos at any step.

**Xcode integration:** `mara_silhouette.imageset`, 2x slot.

---

### CH-002 — sprite_security_drone

| Field | Value |
|---|---|
| **Asset ID** | CH-002 |
| **Asset name** | PMCA Security Drone — floating enemy |
| **Priority** | T2 |
| **Purpose** | DroneEnemyNode in PlatformScene. Currently procedural text label. |
| **Required filename** | `sprite_security_drone@2x.png` |
| **Destination folder** | `Assets.xcassets/Characters/sprite_security_drone.imageset/` |
| **Required dimensions** | 128 × 96 px |
| **Aspect ratio** | 4:3 |
| **Transparency** | Yes |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 2.5 |
| **Seed policy** | Random |
| **Batch count** | 12 |
| **Img2Img** | No |
| **Img2Img strength** | N/A |
| **Status** | Missing |

**Prompt:**
```
pixel art game sprite, small hovering surveillance drone, side view, smooth dark ovoid metal body, single large glowing amber oval sensor eye, two small folded antenna struts, faint teal thruster glow underneath, [GSL], 4-colour palette, flat pixel art, transparent background, 1990s science fiction drone design, clean strong silhouette readable at 32 pixels wide
```

**Asset-specific negative prompt:**
```
wheels, legs, wings, complex detail, white background, multiple drones, human figures, photorealistic
```

**Post-processing:** Remove background → posterize level 4 → **scale DOWN to 128 × 96 nearest-neighbour** → verify silhouette reads at 32 × 24 pt logical size.

**Xcode integration:** `sprite_security_drone.imageset`, 2x slot.

---

### UI-001 — icon_stamp_approved

| Field | Value |
|---|---|
| **Asset ID** | UI-001 |
| **Asset name** | Stamp frame — APPROVED |
| **Priority** | T2 |
| **Required filename** | `icon_stamp_approved@2x.png` |
| **Destination folder** | `Assets.xcassets/UI/icon_stamp_approved.imageset/` |
| **Required dimensions** | 128 × 128 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 8 |
| **CFG** | 2.5 |
| **Batch count** | 12 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
pixel art icon, rubber stamp impression, oval shape border only, dark forest green faded ink, worn distressed stamp border, irregular ink bleed at edges, transparent interior, flat overhead view, [GSL], 2-colour maximum (dark green ink, transparent), no text, no letters, bureaucratic document stamp frame
```

**Post-processing:** Remove background → reduce to 2 colours (dark green ink, transparent) → scale down to 128 × 128 nearest-neighbour.

**Xcode integration:** `icon_stamp_approved.imageset`, 2x slot.

---

### UI-002 through UI-006 — Remaining Stamp Icons

Same settings as UI-001. Change only the colour and shape per stamp.

| ID | Name | Filename | Shape | Ink colour |
|---|---|---|---|---|
| UI-002 | REJECTED | `icon_stamp_rejected@2x.png` | Heavy rectangle with rounded corners | Dark crimson `#6B1A0A` |
| UI-003 | CENSORED | `icon_stamp_censored@2x.png` | Thick filled square / redaction bar | Near-black `#0D0D0D` |
| UI-004 | FORWARD | `icon_stamp_forward@2x.png` | Oval with arrow silhouette | Dark amber `#6B4A00` |
| UI-005 | ARCHIVE | `icon_stamp_archive@2x.png` | Rectangle with filing box silhouette | Dark teal `#00404A` |
| UI-006 | FLAG | `icon_stamp_flag@2x.png` | Diamond / triangle frame | Dark amber-rust `#6B3A00` |

**Prompt template for each:**
```
pixel art icon, rubber stamp impression, [shape] border only, [colour] faded ink, worn distressed stamp border, irregular ink bleed at edges, transparent interior, flat overhead view, [GSL], 2-colour maximum, no text, no letters, bureaucratic document stamp frame
```

**Status:** All Missing.

---

### UI-007 — icon_pickup_data

| Field | Value |
|---|---|
| **Asset ID** | UI-007 |
| **Asset name** | Data orb — platform level collectible |
| **Priority** | T2 |
| **Required filename** | `icon_pickup_data@2x.png` |
| **Destination folder** | `Assets.xcassets/UI/icon_pickup_data.imageset/` |
| **Required dimensions** | 64 × 64 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 8 |
| **CFG** | 2.5 |
| **Batch count** | 12 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
pixel art icon, small diamond gem shape, amber glowing data orb, dark geometric hexagonal frame, faint teal inner light, floating, transparent background, [GSL], 4-colour palette, flat pixel art game collectible, readable at 16 pixels, 1990s PC game pickup icon
```

**Post-processing:** Remove background → posterize level 4 → scale to 64 × 64 nearest-neighbour.

**Xcode integration:** `icon_pickup_data.imageset`, 2x slot.

---

### UI-008 — icon_cartridge

| Field | Value |
|---|---|
| **Asset ID** | UI-008 |
| **Asset name** | Data cartridge — key item |
| **Priority** | T2 |
| **Required filename** | `icon_cartridge@2x.png` |
| **Destination folder** | `Assets.xcassets/UI/icon_cartridge.imageset/` |
| **Required dimensions** | 64 × 64 px |
| **Aspect ratio** | 1:1 |
| **Transparency** | Yes |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 8 |
| **CFG** | 2.5 |
| **Batch count** | 12 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
pixel art icon, small rectangular data storage cartridge, dark metal body, single amber indicator light on front face, front three-quarter view, transparent background, [GSL], 4-colour palette, flat pixel art icon, 1990s science fiction storage device, readable at 16 pixels
```

**Post-processing:** Remove background → posterize level 4 → scale to 64 × 64 nearest-neighbour.

**Xcode integration:** `icon_cartridge.imageset`, 2x slot.

---

### TX-001 — texture_document_paper

| Field | Value |
|---|---|
| **Asset ID** | TX-001 |
| **Asset name** | Aged paper texture — document overlay |
| **Priority** | T2 |
| **Purpose** | Subtle overlay on DocumentNode aged-paper background. |
| **Required filename** | `texture_document_paper@2x.png` |
| **Destination folder** | `Assets.xcassets/UI/texture_document_paper.imageset/` |
| **Required dimensions** | 512 × 768 px |
| **Aspect ratio** | 2:3 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 8 |
| **CFG** | 2.0 |
| **Batch count** | 4 |
| **Img2Img** | No |
| **Status** | Missing |

**Prompt:**
```
aged paper texture, flat overhead view, cream and warm sepia tones, subtle foxing spots, fine grain, very faint fold lines, low contrast, [GSL], no text, no printing, no ruled lines, pure paper surface only, matte surface, not glossy
```

**Asset-specific negative prompt:**
```
text, writing, printing, ruled lines, bright white, watermarks, logos, any objects
```

**Post-processing:** Desaturate slightly toward `#DED7BD` → reduce opacity to 35% → confirm document text remains readable at this opacity level → resize to 512 × 768.

**Xcode integration:** `texture_document_paper.imageset`, 2x slot. Requires code change in DocumentNode to use as multiply-blended overlay.

---

### SP-001 to SP-008 — Chapter Splash Screens

| Field | Value |
|---|---|
| **Asset IDs** | SP-001 through SP-008 |
| **Priority** | T3 |
| **Required filenames** | `splash_ch1@2x.png` through `splash_ch8@2x.png` |
| **Required dimensions** | 512 × 256 px |
| **Aspect ratio** | 2:1 |
| **Transparency** | No |
| **Primary model** | DreamShaper XL Turbo |
| **Sampler** | Euler |
| **Steps** | 10 |
| **CFG** | 3.0 |
| **Batch count** | 6 per chapter |
| **Status** | Missing — deferred |

Generate once all T1/T2 art is approved and the style is fully locked.

---

## Audio Asset List

| ID | Filename | Scene | Notes | Status |
|---|---|---|---|---|
| AUD-001 | `ambient_boot.mp3` | BootScene | Single-tone drone, 30 s loop | Missing |
| AUD-002 | `ambient_mainmenu.mp3` | MainMenuScene | Slow ambient, 60 s loop | Missing |
| AUD-003 | `ambient_desk.mp3` | DeskScene | Office hum, paper rustle bed, 60 s loop | Missing |
| AUD-004 | `ambient_platform.mp3` | PlatformScene | Industrial tension, 60 s loop | Missing |
| AUD-005 | `chapter_complete.mp3` | ChapterCompleteScene | Melancholic swell, 20 s one-shot | Missing |
| AUD-006 | `ambient_ending.mp3` | EndingScene | All endings share this track | Missing |
| AUD-007 | `sfx_stamp.mp3` | DeskScene stamp | Heavy rubber stamp, 0.5 s | Missing |
| AUD-008 | `sfx_page_turn.mp3` | Document advance | Paper shuffle, 0.3 s | Missing |
| AUD-009 | `sfx_terminal_beep.mp3` | Terminal interaction | CRT blip, 0.2 s | Missing |
| AUD-010 | `sfx_drone_alert.mp3` | PlatformScene drone | Electronic warning chirp, 0.8 s | Missing |

---

## Asset Status Master Checklist

| ID | Filename | Tier | Status |
|---|---|---|---|
| P-001 | portrait_mara@2x.png | T1 | **Approved** — `mara_venn_v1_approved.png` |
| P-002 | portrait_audit_voice@2x.png | T1 | Missing |
| P-003 | portrait_calyx@2x.png | T1 | **Approved** — `calyx_v1_approved.png` |
| P-004 | portrait_jun_vale@2x.png | T1 | Missing |
| P-005 | portrait_saint_orra@2x.png | T2 | **Approved** — `saint_orra_v1_approved.png` |
| P-006 | portrait_elias_venn@2x.png | T2 | Missing |
| P-007 | portrait_pmca_director@2x.png | T1 | **Approved** — `pmca_director_v1_approved.png` |
| BG-001 | bg_desk_office@2x.png | T1 | Missing |
| BG-002 | bg_main_menu@2x.png | T1 | Missing |
| BG-003 | bg_chapter_complete@2x.png | T2 | Missing |
| BG-004 | bg_ending_broadcast@2x.png | T3 | Missing |
| BG-005 | bg_ending_control@2x.png | T3 | Missing |
| BG-006 | bg_ending_erasure@2x.png | T3 | Missing |
| BG-007 | bg_boot_screen@2x.png | T3 | Missing |
| PL-001 | bg_city_far@2x.png | T1 | Missing |
| PL-002 | bg_facility_mid@2x.png | T1 | Missing |
| PL-003 | bg_facility_near@2x.png | T1 | Missing |
| CH-001 | mara_silhouette@2x.png | T1 | Missing |
| CH-002 | sprite_security_drone@2x.png | T2 | Missing |
| UI-001 | icon_stamp_approved@2x.png | T2 | Missing |
| UI-002 | icon_stamp_rejected@2x.png | T2 | Missing |
| UI-003 | icon_stamp_censored@2x.png | T2 | Missing |
| UI-004 | icon_stamp_forward@2x.png | T2 | Missing |
| UI-005 | icon_stamp_archive@2x.png | T2 | Missing |
| UI-006 | icon_stamp_flag@2x.png | T2 | Missing |
| UI-007 | icon_pickup_data@2x.png | T2 | Missing |
| UI-008 | icon_cartridge@2x.png | T2 | Missing |
| TX-001 | texture_document_paper@2x.png | T2 | Missing |
| SP-001…8 | splash_ch[N]@2x.png | T3 | Missing |
| AUD-001…10 | (see audio list) | T1–T2 | Missing |

---

*v4.0 — 2026-06-01. Four portraits approved. Style authority: `docs/art/PortraitStyleReference.md` (portraits), `Docs/ArtStyleGuide.md` (all assets). P-003 Calyx description updated to match approved portrait. P-007 PMCA Director added. All portrait background colours corrected to medium blue-grey to match approved canon.*
