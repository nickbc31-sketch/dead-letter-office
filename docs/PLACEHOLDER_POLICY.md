# Dead Letter Office — Placeholder Asset Policy

**Status:** Active  
**Last updated:** 2026-06-01  

---

## Core Rule

**The game must build, launch, and be playable with zero final art assets.** Placeholders — procedural colour fills, labelled text nodes, or coloured rectangles — are the default rendering state for all visual assets. Final art is an upgrade, not a dependency.

This rule applies at every stage of development: a missing PNG never causes a crash, a failed load, or a blank screen.

---

## How Placeholders Work in This Project

Every image load in the codebase is guarded by an existence check before use. If the named asset is absent from the bundle, the code falls through to a procedural fallback automatically. No manual intervention is required.

### Portrait images (DialogueScene)

```swift
if UIImage(named: asset) != nil {
    portraitNode.texture = SKTexture(imageNamed: asset)
    portraitNode.color = .clear
    portraitNode.colorBlendFactor = 0
} else {
    // Placeholder: generates a distinct colour per speaker name
    portraitNode.texture = nil
    portraitNode.color = generatePlaceholderPortraitColor(for: line.speaker)
    portraitNode.colorBlendFactor = 1
}
```

**Behaviour when portrait is missing:** Portrait frame fills with a deterministic colour derived from the speaker's name hash. Each character always gets the same colour on every run, so the distinction between characters is maintained during development.

### Platform background layers (PlatformScene)

```swift
if UIImage(named: layer.imageName) != nil {
    let sprite = SKSpriteNode(imageNamed: layer.imageName)
    // ...
} else {
    // Placeholder: procedural city silhouette with buildings, rain, window lights
    node.addChild(buildProceduralBackground(layer: layer, width: ..., height: ...))
}
```

**Behaviour when background is missing:** A procedural dark skyline with randomised building silhouettes, rain streaks, and amber window lights is generated at runtime. Visually reads as the correct genre even without final art.

### Player sprite (MaraPlayerNode)

```swift
if UIImage(named: "mara_silhouette") != nil {
    bodyNode = SKSpriteNode(imageNamed: "mara_silhouette")
} else {
    // Placeholder: coloured rectangle at correct proportions
    bodyNode = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.8),
                            size: CGSize(width: 32, height: 48))
}
```

**Behaviour when sprite is missing:** Player is rendered as an amber rectangle of correct proportions. Gameplay is fully testable.

### All other scenes (DeskScene, MainMenuScene, etc.)

These scenes draw their backgrounds and UI elements entirely from SpriteKit procedural primitives (colours, shapes, labels). No bitmap image is required for them to render correctly.

---

## Asset Replacement Procedure

Replacing a placeholder with final art requires **no code changes**.

1. Generate the asset following `Docs/AssetProductionPlan.md`.
2. Name the file exactly as specified (lowercase, underscores, correct suffix — e.g. `portrait_mara@2x.png`).
3. In Xcode, open `Assets.xcassets`.
4. Navigate to the correct `.imageset` folder (create it if it doesn't exist yet — see below).
5. Delete any existing placeholder PNG in that imageset.
6. Drag the new PNG into the imageset.
7. Confirm Xcode shows the file at the `2x` resolution slot. If not, open `Contents.json` in the imageset and set `"scale": "2x"` in the images array.
8. Build and run. The new asset loads automatically via `SKTexture(imageNamed:)` — no code change needed.
9. Update the status in `Docs/AssetProductionPlan.md` from `Missing` to `Approved`.

### Creating a new imageset

If the imageset folder does not exist yet in `Assets.xcassets`:

1. Right-click the appropriate group in the asset catalogue (e.g. `Portraits`).
2. Choose **New Image Set**.
3. Name it exactly (e.g. `portrait_mara` — no `@2x` suffix in the imageset name).
4. Drag the `@2x.png` into the `2x` slot.

---

## Folder Structure for Final Art

All visual assets live inside `Assets.xcassets`. The expected subfolder structure:

```
Assets.xcassets/
├── Portraits/
│   ├── portrait_mara.imageset/
│   ├── portrait_audit_voice.imageset/
│   ├── portrait_calyx.imageset/
│   ├── portrait_jun_vale.imageset/
│   ├── portrait_saint_orra.imageset/
│   └── portrait_elias_venn.imageset/
├── Backgrounds/
│   ├── bg_desk_office.imageset/
│   ├── bg_main_menu.imageset/
│   ├── bg_chapter_complete.imageset/
│   ├── bg_city_far.imageset/
│   ├── bg_facility_mid.imageset/
│   ├── bg_facility_near.imageset/
│   ├── bg_ending_broadcast.imageset/
│   ├── bg_ending_control.imageset/
│   ├── bg_ending_erasure.imageset/
│   ├── bg_boot_screen.imageset/
│   └── splash_ch[1-8].imageset/
├── Characters/
│   ├── mara_silhouette.imageset/
│   └── sprite_security_drone.imageset/
└── UI/
    ├── icon_stamp_approved.imageset/
    ├── icon_stamp_rejected.imageset/
    ├── icon_stamp_censored.imageset/
    ├── icon_stamp_forward.imageset/
    ├── icon_stamp_archive.imageset/
    ├── icon_stamp_flag.imageset/
    ├── icon_pickup_data.imageset/
    ├── icon_cartridge.imageset/
    └── texture_document_paper.imageset/
```

None of these folders need to exist until the corresponding asset is ready to import. The game runs without them.

---

## What Must Never Happen

- **Never add a forced-unwrap on a texture load.** All `SKTexture(imageNamed:)` calls that could fail must be preceded by `UIImage(named:) != nil`, or must use `SKSpriteNode(color:size:)` as the fallback path.
- **Never make a scene's `didMove(to:)` conditional on an asset being present.** Scenes must complete setup regardless of asset state.
- **Never hard-code asset dimensions that differ from the placeholder size.** If code assumes an image is 392 × 392, the placeholder must be the same logical size so layout doesn't break.
- **Never ship a build with forced placeholder colours** as final art. The placeholder system is a development tool, not a visual design choice.

---

## Verification Checklist

Run this check after any code or asset change that touches image loading:

- [ ] Build succeeds with all imagesets empty (no PNGs imported).
- [ ] All scenes load and render without errors in the simulator.
- [ ] No crash or hang when a named asset is missing.
- [ ] Portrait DialogueScene shows distinct placeholder colours per speaker.
- [ ] PlatformScene renders a procedural background when all platform layers are absent.
- [ ] MaraPlayerNode renders as a coloured rectangle when `mara_silhouette` is absent.
- [ ] After adding a final art PNG, it appears correctly without any code change.

---

## Current Status (2026-06-01)

- `Assets.xcassets` contains only `AppIcon` and `AccentColor`.
- All 27+ image assets are **Missing** — game runs entirely on procedural placeholders.
- Build is green. All scenes render. Gameplay is testable.
- See `Docs/AssetProductionPlan.md` for full asset list and generation instructions.
