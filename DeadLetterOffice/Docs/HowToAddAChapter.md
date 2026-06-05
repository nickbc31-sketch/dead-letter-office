# How to Add a New Chapter

## Step 1: Add chapter to chapters.json

Open `Data/Chapters/chapters.json` and add a new chapter object to the array:

```json
{
  "id": "ch9",
  "title": "IX. YOUR CHAPTER TITLE",
  "subtitle": "Brief chapter premise.",
  "splashImageName": "splash_ch9",
  "ambientMusicTrack": "ambient_desk",
  "segments": [
    {
      "id": "seg_ch9_desk",
      "mode": "desk",
      "resourceID": "cases_ch9",
      "requiredFlags": null,
      "setsFlags": ["ch9_desk_complete"]
    }
  ],
  "unlockRequires": ["ch9_unlocked"],
  "summary": "What this chapter is about."
}
```

## Step 2: Create the cases file

Create `Data/Cases/cases_ch9.json` containing an array of CaseFile objects.
See `Docs/HowToAddACase.md` for the case structure.

## Step 3: Create the level file (if platform segment)

If your chapter includes a platform segment, create `Data/Levels/level_ch9.json`.
See `Docs/HowToAddALevel.md` for the level structure.

## Step 4: Create dialogue files

If your chapter has opening or mid-chapter dialogue, create a dialogue JSON file
in `Data/Dialogues/` and reference it in the chapter's segment list with `mode: "dialogue"`.

## Step 5: Add chapter splash art

Place `splash_ch9.png` in `Art/UI/` (or `Assets.xcassets`).
See `Art/GeneratedArtPromptList.md` for AI art generation prompts.

## Step 6: Set unlock flags

Make sure a previous chapter's case or level sets the flag `ch9_unlocked`
via its `followUpFlags` or `consequences.flagsSet`.

## Segment modes

- `desk` — loads a desk scene with cases from `resourceID` JSON file
- `platform` — loads a platform level from `resourceID` JSON file
- `dialogue` — plays a dialogue sequence from `resourceID` JSON file
- `ending` — triggers the ending evaluation (only for chapter 8)

## Important: Chapter ordering

Chapters are displayed in order from `chapters.json`. Keep the chapter order narrative-correct.
The `unlockRequires` flags are the gate — they don't have to match chapter index order.
