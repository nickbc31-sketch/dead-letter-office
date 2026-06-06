# Dead Letter Office — Approved Portrait Generation Settings

**Purpose:** Records the exact generation parameters for every approved character portrait. These settings are the ground truth for recreating or revising a portrait. Never generate a replacement portrait without consulting this record first.

**Last updated:** 2026-06-05

---

## How to Use This Document

When a portrait is approved:

1. Record all generation parameters in the relevant character entry below.
2. Move the file from `assets/assets/Portraits/generated/` to `assets/assets/Portraits/Approved/`.
3. Update the status in `Docs/AssetProductionPlan.md` from `Missing` to `Approved`.
4. Update `docs/art/PortraitStyleReference.md` if the approved portrait reveals any style rule that was not previously documented.

If a portrait needs revision or a new version needs to be generated to match an approved character:
- Use the recorded seed as a starting point.
- Do not change Steps, CFG, or Sampler without noting the deviation in this document.
- Generate into `assets/assets/Portraits/generated/` and do not overwrite the approved file until the new version has been reviewed.

---

## Approved Portrait Records

---

### Mara Venn

| Field | Value |
|---|---|
| **Character** | Mara Venn |
| **Role** | Protagonist, PMCA Review Clerk |
| **Approved file** | `assets/assets/Portraits/Approved/mara_venn_v1_approved.png` |
| **Version** | v1 |
| **Approval date** | 2026-06-01 |
| **Model** | DreamShaper XL Turbo |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | Three-quarter view (~35°). Black hair updo. Dark steel-blue PMCA uniform. Two small gold collar pins. Medium blue-grey background. Defines lighting direction and background value for all other portraits. |

---

### Director Calyx

| Field | Value |
|---|---|
| **Character** | Director Calyx |
| **Role** | Antagonist |
| **Approved file** | `assets/assets/Portraits/Approved/calyx_v1_approved.png` |
| **Version** | v1 |
| **Approval date** | 2026-06-01 |
| **Model** | DreamShaper XL Turbo |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | Near-frontal view. East Asian man, black hair, intense controlled expression. Dark civilian authority suit + tie. More dramatic shadow contrast than Mara. Visible contour lines at jaw and brow. |

---

### Saint Orra

| Field | Value |
|---|---|
| **Character** | Saint Orra |
| **Role** | Historical resistance figure (officially erased) |
| **Approved file** | `assets/assets/Portraits/Approved/saint_orra_v1_approved.png` |
| **Version** | v1 |
| **Approval date** | 2026-06-01 |
| **Model** | DreamShaper XL Turbo |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | Near-frontal view. Shoulder-length loose black hair. Warm brown civilian coat, dark undershirt. Weathered expression, under-eye shadow, tired conviction. Warmer skin tone than Mara. Most visible line reinforcement of the four. |

---

### PMCA Director

| Field | Value |
|---|---|
| **Character** | PMCA Director |
| **Role** | Senior PMCA authority figure |
| **Approved file** | `assets/assets/Portraits/Approved/pmca_director_v1_approved.png` |
| **Version** | v1 |
| **Approval date** | 2026-06-01 |
| **Model** | DreamShaper XL Turbo |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | Near-frontal view. Older man, grey hair combed to side, grey mustache. Dark civilian authority suit + tie. Most tonal complexity of the four — older face with defined jowls, forehead structure. Slightly lighter/more neutral background than Mara and Calyx. |

---

### Elias Venn

| Field | Value |
|---|---|
| **Character** | Elias Venn |
| **Role** | Mara's brother — officially declared dead |
| **Approved file** | `assets/assets/Portraits/Approved/elias_venn_v1_approved.png` |
| **Catalog file** | `DeadLetterOffice/Assets.xcassets/portrait_elias_venn.imageset/portrait_elias_venn.png` |
| **Version** | v1 |
| **Approval date** | 2026-06-05 |
| **Model** | DreamShaper XL Turbo |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Img2Img** | Yes — `portrait_mara` at ~0.20 strength (sibling resemblance) |
| **Notes** | Young East Asian man, angular features resembling Mara. Ghostly quality (~85% opacity in post). Very dark near-black background. Imported to catalog at 512×512 to match other portrait imagesets. **Do not regenerate.** |

---

## Pending Portrait Records

The following characters have planned entries but have not yet been generated and approved. Record settings here as each portrait is completed.

---

### The Audit Voice

| Field | Value |
|---|---|
| **Character** | The Audit Voice |
| **Role** | Automated surveillance overseer — no face, no body |
| **Target file** | `assets/assets/Portraits/Approved/portrait_audit_voice_v1_approved.png` |
| **Version** | v1 — pending |
| **Approval date** | [NOT YET APPROVED] |
| **Model** | [TO BE RECORDED] |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | No face. Abstract surveillance entity — geometric dark mask with single horizontal amber glowing slit. No standard portrait rules apply except flat shading and hard edges. Background may use near-black for this character only, to emphasise the void nature of the entity. |

---

### Jun Vale

| Field | Value |
|---|---|
| **Character** | Jun Vale |
| **Role** | Resistance contact — alive but officially dead |
| **Target file** | `assets/assets/Portraits/Approved/portrait_jun_vale_v1_approved.png` |
| **Version** | v1 — pending |
| **Approval date** | [NOT YET APPROVED] |
| **Model** | [TO BE RECORDED] |
| **Seed** | [TO BE RECORDED] |
| **Steps** | [TO BE RECORDED] |
| **CFG** | [TO BE RECORDED] |
| **Sampler** | [TO BE RECORDED] |
| **Scheduler** | [TO BE RECORDED] |
| **Generation date** | [TO BE RECORDED] |
| **Notes** | Near-frontal or slight three-quarter. Civilian/resistance clothing. Must be visually distinct from all four approved portraits. Check silhouette first. |

---

## Settings Log — Revision History

Use this section to record any portrait that was revised after initial approval.

| Date | Character | Version | Change reason | Seed | Notes |
|---|---|---|---|---|---|
| — | — | — | — | — | No revisions recorded yet |

---

*Record generation settings here immediately after each portrait is approved. Do not rely on DiffusionBee history — it is not persistent.*
