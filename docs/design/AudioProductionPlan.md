# Dead Letter Office — Audio Production Plan

**Version:** 1.0  
**Date:** 2026-06-02  
**Source:** Project Bible v4.0, CANON.md, AudioManager.swift (call sites mapped)  
**Subscription:** Epidemic Sound  
**Status:** Planning only — no audio sourced or implemented

---

## Overview

Dead Letter Office is a premium offline iOS game. The audio design must carry the weight that the deliberately minimal visual style cannot. The game has no voiced characters, no cutscenes with motion, and no action-movie pacing. Audio is the primary emotional delivery mechanism.

### Sonic Identity

**Core palette:** Cold analog synth + distant industrial hum + deliberate silence  
**Contrast element:** Warm acoustic texture (the Quiet Choir, the human cost of the system)  
**Reference tones:** Papers Please, Beneath a Steel Sky, Disco Elysium desk scenes  
**Technical constraints:** iPhone speakers, headphones, silent listening — must work at low volume  
**Avoid:** Upbeat electronica, orchestral swells, recognisable melody hooks, anything that feels game-like rather than oppressive

---

## Implementation Status Summary

### Audio Wired (files missing, code ready):

| Filename | Scene/Call Site | Status |
|---|---|---|
| `ambient_boot.mp3` | BootScene | Wired, file missing |
| `ambient_mainmenu.mp3` | MainMenuScene | Wired, file missing |
| `ambient_desk.mp3` | DeskScene | Wired, file missing |
| `ambient_platform.mp3` | PlatformScene (fallback) | Wired, file missing |
| `chapter_complete.mp3` | ChapterCompleteScene | Wired, file missing |
| `ambient_ending.mp3` | EndingScene | Wired, file missing |
| `stamp.wav` | DeskScene — all stamp actions | Wired, file missing |
| `page_turn.wav` | DeskScene — tab switch | Wired, file missing |
| `terminal_beep.wav` | PlatformScene — terminal interact | Wired, file missing |
| `drone_alert.wav` | PlatformScene — drone detection | Wired, file missing |

### Audio Not Yet Wired (requires code + file):

Stamp action differentiation, dialogue advance, save complete, message received, PMCA alerts, boot stinger, glitch moment (C05), Audit Voice processing.

---

## PART 1 — MUSIC

All music tracks are looping ambient beds unless noted as one-shot. Target format: MP3, 44.1kHz, 128–192kbps. Loops should be seamless with no obvious loop point.

---

### M-01: Main Menu

**Filename:** `ambient_mainmenu.mp3`  
**Scene:** MainMenuScene  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** High — first music the player hears

**World context:** The player is in the PMCA archive at night, before their shift begins. The city of Veyr is outside, wet and closed. The menu represents the threshold between the ordinary world and the machinery of grief management.

**Mood:** Institutional dread at rest. Slow, cold, slightly bureaucratic. Not frightening — oppressively calm. The silence of a place where important things happen that nobody talks about.

**Sonic characteristics:**
- Sparse, deliberate arrangement
- Sub-bass hum, like server rooms or distant HVAC
- Very slow synth pads (long attack, long decay)
- Optional: single distant piano note every 8–12 bars
- No rhythm, no drums, no pulse
- BPM reference: 55–65 (if any rhythmic element)

**Epidemic Sound Search Terms:**
- `dark ambient synth slow`
- `dystopian atmospheric drone`
- `minimal ambient tension no drums`
- `cold industrial ambient night`
- `melancholic synth pad slow loop`

**Avoid:** Anything with a recognisable hook, upbeat energy, or natural/organic texture.

---

### M-02: PMCA Desk Work (primary desk loop)

**Filename:** `ambient_desk.mp3`  
**Scene:** DeskScene  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** High — plays for most of the game's total runtime

**World context:** Mara sits at her terminal in the PMCA processing room. Fluorescent light. The sound of other clerks, muffled. The weight of the work itself — classifying, approving, erasing. This music plays during every case in every chapter.

**Mood:** Low-key bureaucratic tension. The hum of a system processing. Not tense — that comes from the documents. The desk music should feel like the room itself breathing.

**Sonic characteristics:**
- Looping synth texture with very subtle rhythmic pulse (60–75 BPM)
- Tape hiss or vinyl noise optional (aged analog feel)
- Subtle filtered noise sweep every 8–12 bars to prevent listener fatigue
- Should feel like it could play for 30 minutes without becoming irritating
- Amber warmth in the mid register, cold blue in the background

**Epidemic Sound Search Terms:**
- `ambient tension subtle pulse`
- `dark minimal electronic loop`
- `office hum synth texture`
- `low key dystopian electronic`
- `tense ambient bureaucratic`

**Note:** This is the single most important music track in the game. If only one track is sourced, it is this one.

---

### M-03: Investigation / Contradiction Discovery

**Filename:** Not yet wired — requires code addition  
**Scene:** DeskScene (variant layer when contradiction panel is revealed, or triggered programmatically)  
**Duration:** 30–45 seconds (one-shot stinger or short loop)  
**Priority:** Medium — enhances contradiction discovery moment

**World context:** The player has found the inconsistency — the timestamp doesn't match, the seal is wrong, the message is impossible. Something shifts.

**Mood:** Subtle tension increase. Not dramatic — a tightening. Like a document that was slightly damp when it shouldn't be.

**Sonic characteristics:**
- Can be a short stinger (6–10 seconds) or a distinct desk variant
- Slightly higher frequency content than desk loop
- A faint dissonant note or interval
- Should not feel like a "success jingle" — more like unease

**Epidemic Sound Search Terms:**
- `tension stinger subtle`
- `discovery sting minimal`
- `dark suspense short`
- `dissonant synth hit short`

**Implementation note:** Could be implemented as an additive layer (second audio player) rather than replacing the desk loop. AudioManager does not currently support layered audio — this is a future feature.

---

### M-04: Platform Sections (general)

**Filename:** `ambient_platform.mp3` (fallback); chapter-specific tracks override if `ambientMusicTrack` is set in LevelData  
**Scene:** PlatformScene  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** High — plays during all 8 platform levels

**World context:** Mara has left the desk. She is in the maintenance corridors, service tunnels, or the archive train. The city is physically present for the first time.

**Mood:** Urban industrial tension. Movement, risk, the city as infrastructure. Not an action track — more like the sound of a facility that is always working even when no one is watching.

**Sonic characteristics:**
- Rhythmic pulse: 90–110 BPM, but subtle — distant, not driving
- Industrial percussion or processed noise rhythm
- Teal metallic tone in upper mids
- Low rumble suggesting scale (the city beneath the city)
- Must not feel like a "game level" track — should feel like a space

**Epidemic Sound Search Terms:**
- `industrial ambient loop`
- `dark electronic rhythmic tension`
- `dystopian platform synth`
- `urban underground electronic pulse`
- `tension thriller electronic minimal`

---

### M-05: Quiet Choir Sections

**Filename:** Not yet wired — `ambient_choir.mp3` (suggest)  
**Scene:** PlatformScene (P07 Undercity Refuge); DialogueScene when Jun Vale speaks  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** Medium — contrast moment crucial to emotional arc

**World context:** Mara reaches the Quiet Choir's undercity refuge. The people declared legally dead. The difference between their space and the PMCA is the difference between handmade and institutional.

**Mood:** Warmth within darkness. Not safe — still underground — but human. The sound of people who have built something real in a world that erased them.

**Sonic characteristics:**
- Introduce the game's first warm, organic texture
- Low acoustic element (plucked string, soft piano, or breath-like pad)
- Quiet — intimate scale rather than cinematic scale
- Harmonic — the Quiet Choir's name refers to their musical nature
- Should feel like a contrast with everything that came before it

**Epidemic Sound Search Terms:**
- `intimate acoustic ambient`
- `underground shelter quiet`
- `minimalist piano dark ambient`
- `human warmth underground acoustic`
- `soft dystopian ambient organic`

**Note:** This is the game's emotional release valve. The contrast with the cold desk music is narratively essential.

---

### M-06: Helix Meridian Sections

**Filename:** Not yet wired — `ambient_meridian.mp3` (suggest)  
**Scene:** DeskScene (Ch5: Afterlife Premium cases); PlatformScene P05  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** Low — context-specific

**World context:** Mara encounters Helix Meridian's premium grief services — the luxury tier of death administration. Clean glass, processed air, tailored silence.

**Mood:** Corporate sterile. Beautiful on the surface in a way that is deeply wrong. Money as aesthetic. The sound of a place that has been designed to not contain anything uncomfortable.

**Sonic characteristics:**
- Pristine, high-fidelity synth
- Almost no noise, no grain, no texture — too clean
- Glass-like tones
- Subtle but present — not obviously sinister, but unsettling in context
- Could function as "ambient techno" in another context

**Epidemic Sound Search Terms:**
- `corporate minimal ambient`
- `clean futuristic synth loop`
- `sterile electronic ambient`
- `glass synth atmospheric minimal`
- `tech dystopia clean`

---

### M-07: Chapter Endings / Chapter Complete

**Filename:** `chapter_complete.mp3`  
**Scene:** ChapterCompleteScene  
**Duration:** 15–25 seconds (one-shot, plays once)  
**Priority:** Medium

**World context:** The shift ends. What Mara decided has happened somewhere in the system. The chapter card appears with a summary of events.

**Mood:** Melancholic resolution. Not victory, not defeat — consequence. The feeling of having participated in something that continued without you.

**Sonic characteristics:**
- One-shot stinger, not a loop
- Sparse — two or three elements maximum
- Low synth swell that does not resolve
- Optional: a single piano note or distant bell
- Should feel like a door closing

**Epidemic Sound Search Terms:**
- `melancholic ambient stinger`
- `reflective cinematic short`
- `sad resolution short ambient`
- `emotional moment minimal stinger`
- `quiet dramatic sting`

---

### M-08: Three Endings

**Filename:** `ambient_ending.mp3` (single file; all three endings share one track)  
**Scene:** EndingScene  
**Duration:** 60–90 seconds (one-shot or loop, plays during ending card)  
**Priority:** High — final impression of the game

**World context:** The game's last moment. Three possible outcomes:
- **Broadcast (A):** Mara released the archive. The city hears what was buried. Hope, but at cost.
- **Control (B):** Mara complied. The system continues. Corporate order maintained.
- **Erasure (C):** Neither. Mara is erased. Her record deleted.

**Mood:** Consequence in the present tense. The feeling after the decision, not during it. Should work emotionally for all three endings without undermining any.

**Sonic characteristics:**
- Long, sustained, evolving
- Neither clearly positive nor clearly negative
- Space and silence are part of the composition
- Should grow or shift once over its duration
- Broadcast: lean toward warmth; Control: lean toward cold; Erasure: lean toward silence

**Sourcing note:** One versatile ambient track that serves all three endings is acceptable for launch. Chapter-specific ending variants can be added post-release.

**Epidemic Sound Search Terms:**
- `cinematic ambient ending`
- `emotional drone slow evolving`
- `consequence ambient dark`
- `dystopian resolution atmospheric`
- `slow burn ambient melancholy`

---

### M-09: Boot Screen (optional)

**Filename:** `ambient_boot.mp3`  
**Scene:** BootScene  
**Duration:** 15–30 seconds (one-shot; boot screen is brief)  
**Priority:** Low — boot screen is ~5 seconds

**Mood:** System initialisation. Cold digital tone. Like a terminal coming online.

**Epidemic Sound Search Terms:**
- `terminal startup sound`
- `electronic boot tone`
- `digital initialisation`
- `short dark ambient tone`

---

## PART 2 — AMBIENCE

Ambience layers are distinct from music — they are the physical sound of a space rather than a composed track. They may layer UNDER the music or play alone. All ambience loops: target 60–120 seconds, seamless.

**Implementation note:** AudioManager currently supports one audio track at a time. Ambience layering requires either: (a) baking ambience into the music track, or (b) extending AudioManager to support a separate ambience channel. Recommendation: bake ambience into music for Chapter 1 launch; add separate ambience channel in a later build.

---

### A-01: Office Hum (PMCA Processing Room)

**Filename:** Baked into `ambient_desk.mp3` for Ch1; standalone `amb_office.mp3` for future  
**Scenes:** DeskScene  
**Duration:** 60–120 seconds (seamless loop)  
**Priority:** High (baked into desk track)

**Mood:** The continuous hum of institutional life. Fluorescent lights, distant ventilation, the suggestion of other clerks in other rooms.

**Sonic characteristics:**
- 50Hz/60Hz electrical hum at very low level
- Distant HVAC noise (white noise + slow modulation)
- Occasional distant sound: paper shuffle, muffled terminal keypress
- Should be near-inaudible at normal listening volume — felt more than heard

**Epidemic Sound Search Terms:**
- `office ambience loop`
- `fluorescent hum quiet`
- `indoor institutional ambience`
- `bureaucratic office room tone`
- `quiet office background noise`

---

### A-02: Archive Room

**Filename:** `amb_archive.mp3` (not yet wired)  
**Scenes:** PlatformScene P01 (Archive Walk), P04 (Records Annex), P08 (Central Archive)  
**Duration:** 90–120 seconds (seamless loop)  
**Priority:** Medium

**World context:** The archive is where the dead are stored. Deep storage, cold temperature, the smell of old data. Vast and silent.

**Mood:** Cold, vast, preserved. A library of the dead. Quiet with the weight of accumulated records.

**Sonic characteristics:**
- Very quiet — the point is the space, not the sound
- Low sub-bass frequency suggesting large room acoustics
- Occasional metallic tick (expansion of cold metal shelving)
- No human sounds
- Slight reverb tail on any transients

**Epidemic Sound Search Terms:**
- `cold archive room ambience`
- `large empty room atmosphere`
- `dark library ambience`
- `cold industrial empty space`
- `eerie quiet space atmosphere`

---

### A-03: Platform / Underground Transit

**Filename:** Baked into `ambient_platform.mp3` for Ch1; `amb_transit.mp3` for future  
**Scenes:** PlatformScene  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** High (baked into platform track)

**World context:** Service tunnels, automated transit corridors. The city's infrastructure. Distant machinery, the rumble of systems in motion.

**Mood:** Active infrastructure. Industrial but not dangerous. The sense of a system running continuously whether or not anyone is watching.

**Sonic characteristics:**
- Distant low rumble (train/conveyor)
- Intermittent mechanical rhythm (belt, gear, pump)
- Occasional drip (condensation in underground spaces)
- Subtle electrical hum variant (different frequency from office)

**Epidemic Sound Search Terms:**
- `underground transit ambience`
- `industrial tunnel atmosphere`
- `subway platform ambience`
- `mechanical underground loop`
- `factory distant room tone`

---

### A-04: Terminal Room / Dialogue Spaces

**Filename:** `amb_terminal.mp3` (not yet wired)  
**Scenes:** DialogueScene  
**Duration:** 60–90 seconds (seamless loop)  
**Priority:** Medium

**World context:** The space where Mara interacts with the Audit Voice, Director Calyx, or Jun Vale. A sterile terminal interface space.

**Mood:** Electronic stillness. The background radiation of a computing environment. Neutral but monitored.

**Sonic characteristics:**
- CRT monitor hum (very subtle high-frequency ring)
- Low-level digital noise (like an old dial-up connection, very attenuated)
- Slow ventilation
- Optional: very faint blip pattern suggesting ongoing system activity

**Epidemic Sound Search Terms:**
- `terminal computer ambient`
- `CRT hum electronic ambience`
- `server room quiet`
- `digital room tone minimal`
- `computer room atmosphere`

---

## PART 3 — SOUND EFFECTS

All SFX: format WAV or AIFF, 44.1kHz, 16-bit. Duration guidelines below are targets; actual sourced files will be trimmed.

---

### SFX-01: Document Tab Switch / Page Turn

**Filename:** `page_turn.wav`  
**Call site:** `AudioManager.shared.playPageTurn(on:)` — fires on every document tab switch in DeskScene  
**Duration:** 0.2–0.4 seconds  
**Priority:** High — fires frequently, must not become irritating

**Mood:** Physical document handling. Paper, not digital. The player is a clerk handling physical records.

**Sonic characteristics:**
- Paper rustle or card flip
- Short, clean, natural decay
- NOT a digital click — the documents feel physical
- Should be satisfying without being prominent

**Epidemic Sound Search Terms:**
- `paper flip short`
- `document page turn`
- `paper rustle single`
- `file card flip`
- `soft paper sound`

---

### SFX-02: Approval Stamp

**Filename:** `stamp_approve.wav` (requires separate SFX wiring by action type)  
**Current filename:** `stamp.wav` (shared with all stamps)  
**Duration:** 0.4–0.6 seconds  
**Priority:** High — most satisfying action in the game

**Mood:** Decisive, physical, bureaucratic authority. The weight of an institutional decision made physical.

**Sonic characteristics:**
- Heavy rubber-on-paper thump
- Slight ink splat component (subtle, not messy)
- Solid low-mid thud with a brief paper slap tail
- Should feel weighty — this is an important action

**Epidemic Sound Search Terms:**
- `rubber stamp hard impact`
- `office stamp thud`
- `document stamp`
- `heavy stamp paper`
- `approval stamp foley`

---

### SFX-03: Rejection Stamp

**Filename:** `stamp_reject.wav` (requires code differentiation)  
**Current filename:** `stamp.wav` (shared)  
**Duration:** 0.4–0.6 seconds  
**Priority:** Medium

**Mood:** Slightly sharper, more percussive than the approval. The snap of denial.

**Sonic characteristics:**
- Similar weight to approval stamp but with more of a crack or snap
- Slightly higher pitch — more harsh
- No ink element — drier

**Epidemic Sound Search Terms:**
- `stamp impact sharp`
- `hard stamp crack`
- `paper impact sharp foley`

---

### SFX-04: Censor Stamp / Marker

**Filename:** `stamp_censor.wav` (requires code differentiation)  
**Current filename:** `stamp.wav` (shared)  
**Duration:** 0.3–0.5 seconds  
**Priority:** Medium

**Mood:** The drag and blot of redaction. More of a smear than a stamp.

**Sonic characteristics:**
- Marker drag across paper (not a stamp thump)
- Could also be a broad flat stamp with more spread
- Should feel like an erasure, not a decision

**Epidemic Sound Search Terms:**
- `marker drag paper`
- `broad stamp paper drag`
- `rubber marker paper`

---

### SFX-05: Illegal Forward / Archive / Flag Anomaly (action group)

**Filename:** `stamp_action.wav` (suggest) — for less-physical, more-procedural actions  
**Current filename:** `stamp.wav` (shared)  
**Duration:** 0.2–0.4 seconds  
**Priority:** Low (differentiation is polish, not core)

**Mood:** Digital routing — something passing through a system rather than being physically handled.

**Sonic characteristics:**
- Soft electronic click or terminal keypress
- Brief synthetic tone tail
- Lighter than physical stamp sounds

**Epidemic Sound Search Terms:**
- `terminal keypress short`
- `routing click electronic`
- `computer input soft`
- `digital confirm short`

---

### SFX-06: Message Received / Dead Letter Arrival

**Filename:** `dead_letter_arrival.wav` (not yet wired)  
**Trigger:** When a new case loads / Dead Letter appears in queue  
**Duration:** 0.5–1.0 seconds  
**Priority:** Medium

**Mood:** Something arriving from a place of death. Not a cheerful notification — a weight appearing.

**Sonic characteristics:**
- Low-pitched electronic tone with slow decay
- Optional: very brief static or hiss leading into the tone
- Should feel like receiving rather than sending
- Distinctly different from UI button sounds

**Epidemic Sound Search Terms:**
- `notification tone dark`
- `message arrive low tone`
- `dead tone electronic short`
- `arrival sound melancholic`
- `low frequency alert tone`

---

### SFX-07: Terminal Beep / Interactive Terminal

**Filename:** `terminal_beep.wav`  
**Call site:** PlatformScene — terminal interaction  
**Duration:** 0.1–0.3 seconds  
**Priority:** Medium

**Mood:** Old computer terminal acknowledging input. Amber phosphor era.

**Sonic characteristics:**
- 8-bit or early digital tone
- Single beep, not two
- Slightly rough — not a clean modern tone
- 800–1200Hz reference range

**Epidemic Sound Search Terms:**
- `retro terminal beep`
- `computer beep old`
- `8-bit acknowledge tone`
- `vintage computer input sound`
- `amber terminal blip`

---

### SFX-08: Button Press / Menu Navigation

**Filename:** `ui_button.wav` (not yet wired)  
**Trigger:** Menu button selections  
**Duration:** 0.1–0.2 seconds  
**Priority:** Low

**Mood:** Mechanical key depression. The buttons feel physical, like old terminal keys.

**Sonic characteristics:**
- Subtle click — not a loud button press
- Short attack, minimal tail
- Slightly mechanical rather than purely digital

**Epidemic Sound Search Terms:**
- `keyboard key click soft`
- `button press quiet`
- `mechanical click short`
- `UI click minimal`

---

### SFX-09: Dialogue Advance

**Filename:** `dialogue_advance.wav` (not yet wired)  
**Trigger:** DialogueScene — player taps to advance line  
**Duration:** 0.05–0.15 seconds  
**Priority:** Low

**Mood:** Text terminal cursor advance. The bureaucratic rhythm of a conversation.

**Sonic characteristics:**
- Very subtle — almost inaudible
- Soft click or paper-thin blip
- Must not compete with dialogue text content

**Epidemic Sound Search Terms:**
- `text advance click silent`
- `cursor move minimal`
- `soft click subtle`

---

### SFX-10: Save Complete

**Filename:** `save_complete.wav` (not yet wired)  
**Trigger:** GameState.save() completes  
**Duration:** 0.3–0.6 seconds  
**Priority:** Low

**Mood:** Data committed. A quiet confirmation that the record was written.

**Sonic characteristics:**
- Soft ascending two-tone
- Not triumphant — procedural
- Slight digital shimmer

**Epidemic Sound Search Terms:**
- `save confirmation quiet`
- `soft chime two tone`
- `data commit tone`
- `gentle confirmation sound`

---

### SFX-11: Drone Alert (Platform)

**Filename:** `drone_alert.wav`  
**Call site:** PlatformScene — drone detects player  
**Duration:** 0.5–1.0 seconds  
**Priority:** Medium

**Mood:** Electronic threat detection. Clinical, automatic, unsympathetic.

**Sonic characteristics:**
- Rising synthetic alarm tone
- Fast attack, short decay
- Should feel like the drone is a machine, not a creature
- Slightly distorted or clipped — industrial surveillance equipment

**Epidemic Sound Search Terms:**
- `drone alert electronic`
- `security alarm short`
- `electronic warning sting`
- `surveillance alert tone`
- `alarm pulse short`

---

### SFX-12: Data Cartridge Pickup

**Filename:** `data_cartridge_pickup.wav` (not yet wired)  
**Call site:** PlatformScene — pickup collision  
**Duration:** 0.2–0.4 seconds  
**Priority:** Low

**Mood:** A small piece of contraband data — something valuable and dangerous.

**Sonic characteristics:**
- Brief electronic chime or data tick
- Short but satisfying
- Should feel like something being captured, not rewarded

**Epidemic Sound Search Terms:**
- `item pickup soft`
- `data pickup blip`
- `electronic collect short`
- `soft reward chime minimal`

---

### SFX-13: Door / Access Unlock

**Filename:** `door_unlock.wav` (not yet wired)  
**Call site:** PlatformScene — door interactable opens  
**Duration:** 0.4–0.8 seconds  
**Priority:** Low

**Mood:** Industrial access door — heavy, not welcoming.

**Sonic characteristics:**
- Mechanical clunk + pneumatic hiss
- Low frequency thud of a sealed door releasing
- Brief metallic scrape optional

**Epidemic Sound Search Terms:**
- `industrial door unlock`
- `heavy door open foley`
- `pneumatic door sound`
- `access door mechanical`

---

### SFX-14: System Glitch / I AM NOT DEAD

**Filename:** `glitch_im_not_dead.wav` (not yet wired)  
**Trigger:** C05 final case — the "I AM NOT DEAD" chapter culmination animation in DeskScene  
**Duration:** 2.0–4.0 seconds (one-shot, plays during glitch animation)  
**Priority:** High — defining narrative moment of Chapter 1

**Mood:** The system breaking. A voice that should not exist. Electronic disturbance that implies consciousness.

**Sonic characteristics:**
- Digital distortion: sample rate reduction, bit crushing effect
- White noise burst with rapid amplitude modulation (stuttering)
- Optional: very low-pitched human vocal fragment buried in the noise (not recognisable as a word — just the impression of voice)
- Should feel like a transmission from somewhere the system didn't account for
- Duration matches the glitch animation (~2 seconds of visual flash + 2 seconds of label visible)

**Epidemic Sound Search Terms:**
- `glitch distortion electronic`
- `system error sound`
- `digital corruption noise`
- `corrupted data audio`
- `electronic disruption burst`

**Note:** This is the only SFX that may benefit from custom audio work rather than library sourcing. A short custom piece from a music producer combining the above elements would be more distinctive. If sourcing from ES, plan to layer two tracks: a glitch burst + a subtle tonal element.

---

## PART 4 — NARRATIVE AUDIO / VOICE PROCESSING

The game has no recorded voice acting. Narrative audio refers to processed/synthesised character audio effects that imply voice without using it.

---

### N-01: Audit Voice Processing

**Purpose:** The Audit Voice is an automated surveillance system — "a polite, neutral, invasive system voice" (CANON.md). It should sound like a voice that has been stripped of humanity by design.

**Not yet implemented** — requires either:
1. A text-to-speech voice processed with effects, OR
2. A synthesised voice/vocal texture

**Mood:** Calm, institutional, algorithmic. Every note of emotional inflection has been removed. Should feel like reading text aloud is something it has been optimised to do rather than something it naturally does.

**Suggested approach for Epidemic Sound:**  
Use an electronic/robot voice texture as an ambient texture under dialogue text — not a voice reading the words, but an ambient suggestion of synthetic speech. This communicates the Audit Voice's nature through texture, not content.

**Epidemic Sound Search Terms:**
- `robot voice texture ambient`
- `synthetic voice electronic`
- `digital speech texture`
- `processed vocal ambient`
- `computer voice atmospheric`

**Alternative approach:** Commission a short custom vocal texture (2–3 seconds of phoneme-like sounds run through bitcrusher + pitch correction) that plays as an ambient loop during Audit Voice lines. Not sourced from Epidemic Sound.

---

### N-02: PMCA System Alerts

**Purpose:** The PMCA system generates automated alerts when the player takes anomalous or suspicious actions. Not a character voice — a system notification.

**Not yet wired** — would play as a short stinger during high-suspicion moments or audit warning events.

**Mood:** Automatic, measured, institutional threat. Not alarming — the system considers this a routine audit event.

**Duration:** 0.5–1.5 seconds (stinger)

**Epidemic Sound Search Terms:**
- `system warning alert tone`
- `institutional alert short`
- `computer notification serious`
- `audit tone electronic`
- `cold alert sting minimal`

---

### N-03: System Announcements (PMCA public address)

**Purpose:** Environmental audio for platform levels — the PMCA's public address system. Ambient suggestions of institutional language without actual speech.

**Not yet wired** — would play at low volume as part of platform ambience.

**Mood:** The voice of the institution: calm, authoritative, everywhere. Not threatening in tone — the threat is in the ubiquity.

**Sonic characteristics:**
- Could be a processed/filtered drone that implies announcement rather than being one
- Or a distant, inaudible PA system suggestion (muffled, warped)
- Should not be distracting

**Epidemic Sound Search Terms:**
- `PA announcement atmosphere distant`
- `muffled announcement background`
- `institutional voice ambient texture`
- `public address system distant`

---

## PART 5 — EPIDEMIC SOUND SOURCING GUIDE

### How to Use This Guide

1. Open [epidemicsound.com](https://www.epidemicsound.com)
2. Use the search terms listed for each item
3. Filter by: **Mood → Dark, Tense, Melancholic** (for music and ambience)
4. Filter by: **Energy → Low** (for most music), **Medium** (for platform sections)
5. Use BPM filter: 55–75 for desk/menu; 90–110 for platform
6. Preview in the context of the game (play the build and preview tracks simultaneously)

### Priority Order for Sourcing Sessions

Work in this order — complete each before moving to the next:

**Session 1 — Core Loop (must have before any playtest)**
1. `ambient_desk.mp3` (M-02) — desk work music loop
2. `stamp.wav` (SFX-02) — approval stamp
3. `page_turn.wav` (SFX-01) — document tab switch
4. `ambient_platform.mp3` (M-04) — platform music

**Session 2 — Navigation and Framing**
5. `ambient_mainmenu.mp3` (M-01) — main menu
6. `chapter_complete.mp3` (M-07) — chapter complete stinger
7. `terminal_beep.wav` (SFX-07) — terminal interaction
8. `drone_alert.wav` (SFX-11) — drone detection

**Session 3 — Narrative Moments**
9. `ambient_ending.mp3` (M-08) — endings
10. `glitch_im_not_dead.wav` (SFX-14) — C05 climax
11. `dead_letter_arrival.wav` (SFX-06) — case arrival tone
12. `ambient_boot.mp3` (M-09) — boot screen

**Session 4 — Atmosphere and Polish**
13. Office and archive ambience (A-01, A-02)
14. Quiet Choir music (M-05)
15. Stamp differentiation (SFX-03, SFX-04, SFX-05)
16. Remaining SFX (SFX-08 through SFX-13)

**Session 5 — World Distinction (Chapter 2+)**
17. Helix Meridian music (M-06)
18. Terminal room ambience (A-04)
19. Narrative audio processing (N-01, N-02, N-03)

---

### What Epidemic Sound Covers Well

| Category | ES Coverage |
|---|---|
| Ambient/atmospheric music loops | Excellent — large catalog, well-tagged |
| Dark electronic / minimal synth | Good — search "dark ambient", "minimal electronic" |
| Industrial/platform texture | Good — "industrial ambient", "underground electronic" |
| Cinematic stingers and one-shots | Good — "tension sting", "discovery hit" |
| Office and indoor ambience | Good — SFX section under "Atmospheres > Everyday" |
| Paper and stamp foley | Good — SFX section under "Foley > Paper" |
| UI sounds | Good — SFX section under "User Interface" |
| Electronic alerts and notifications | Good — SFX section under "Technology" |

### What May Need Alternative Sourcing

| Category | Recommendation |
|---|---|
| Audit Voice character effect (N-01) | Custom processing of TTS; or commission |
| `glitch_im_not_dead.wav` (SFX-14) | Layer multiple ES SFX; or commission a custom piece |
| Quiet Choir warm organic contrast (M-05) | ES has some options — may need to search more creatively ("intimate folk ambient", "acoustic underground") |
| PMCA public address suggestion (N-03) | Bake into platform ambience track rather than sourcing separately |

---

## Implementation Notes for AudioManager

When audio files are ready to drop in, the code is already wired for:

```swift
// Music (drop MP3 into app bundle):
AudioManager.shared.playMusic(named: "ambient_mainmenu")  // no extension needed
AudioManager.shared.playMusic(named: "ambient_desk")
AudioManager.shared.playMusic(named: "ambient_platform")
AudioManager.shared.playMusic(named: "chapter_complete")
AudioManager.shared.playMusic(named: "ambient_ending")
AudioManager.shared.playMusic(named: "ambient_boot")

// SFX (drop WAV into app bundle):
AudioManager.shared.playStamp(on: node)         // plays "stamp.wav"
AudioManager.shared.playPageTurn(on: node)      // plays "page_turn.wav"
AudioManager.shared.playTerminalBeep(on: node)  // plays "terminal_beep.wav"
AudioManager.shared.playDroneAlert(on: node)    // plays "drone_alert.wav"
```

Files missing from the bundle fail silently — no crashes. The game runs without audio; adding files activates them immediately without code changes.

For new SFX not yet wired, add methods to `AudioManager.swift` following the `playStamp` pattern.

---

## File Naming Reference

| Category | Naming Convention | Format |
|---|---|---|
| Music loops | `ambient_[context].mp3` | MP3, 44.1kHz, 128–192kbps |
| Music stingers | `[name].mp3` (one-shot) | MP3, 44.1kHz |
| Ambience | `amb_[space].mp3` | MP3, 44.1kHz |
| Stamp SFX | `stamp_[action].wav` | WAV, 44.1kHz, 16-bit |
| General SFX | `[action_name].wav` | WAV, 44.1kHz, 16-bit |
| UI sounds | `ui_[action].wav` | WAV, 44.1kHz, 16-bit |
| Glitch/special | `[descriptive_name].wav` | WAV, 44.1kHz, 16-bit |

All files drop directly into the Xcode project (drag into Project Navigator → "Copy items if needed" → target membership checked). No code changes required for the six already-wired music tracks.

---

*Plan produced 2026-06-02. Derived from Project Bible v4.0, CANON.md, AudioManager.swift call site mapping, and gameplay validation session. Update when audio is sourced — mark each item Sourced / Pending.*
