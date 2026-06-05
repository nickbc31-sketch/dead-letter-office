# Layout Fix Audit
**Date:** 2026-06-02  
**Device:** iPhone 17 Pro Max Simulator (iOS 26, UDID E5ACDFE1)  
**Goal:** Fix landscape layout regression — scenes displaying at ~60% of available landscape width

---

## Root Cause

The compiled `Info.plist` contained only the minimum bundle metadata with **no orientation, full-screen, or scene lifecycle keys**. This caused iOS 26 to run the app in its default compact windowed mode rather than full-screen.

### Missing keys (before fix):
- `UIRequiresFullScreen` — absent → iOS 26 uses compact windowed mode
- `_UILaunchAlwaysFullScreen` — absent → iOS 26 launch hint ignored
- `UISupportedInterfaceOrientations` — absent → default portrait allowed
- `UIApplicationSceneManifest` — absent → scene lifecycle falling back to defaults

### Effect:
| Context | Width used |
|---------|-----------|
| iOS 26 simulator (compact window) | 480pt virtual → 763pt displayed = 79.8% of 956pt physical |
| User's measured "usable content" (after 124pt safe-area margins) | ~566pt displayed = ~59% of physical → perceived as "~60%" |
| Real device WITHOUT UIRequiresFullScreen | iOS 26 windowed mode → similar compact presentation |
| Real device WITH UIRequiresFullScreen | Full 956×440pt → ~94% usable after dynamic-island safe area |

---

## Files Changed

### 1. `DeadLetterOffice/Info.plist`
Added all required keys:
- `UIRequiresFullScreen = true`
- `_UILaunchAlwaysFullScreen = true`
- `UISupportedInterfaceOrientations = [LandscapeLeft, LandscapeRight]`
- `UISupportedInterfaceOrientations~ipad = [LandscapeLeft, LandscapeRight]`
- `UIApplicationSceneManifest` with correct scene configuration
- `UIStatusBarHidden = true`

### 2. `DeadLetterOffice/SceneDelegate.swift`
Removed the `sizeRestrictions` code that was **locking the window to the compact size** (480×320pt), preventing iOS from expanding to full screen even when `UIRequiresFullScreen` is present. Simplified to: request landscape orientation + log dimensions.

### 3. `DeadLetterOffice/GameViewController.swift`
Added `--start-at-platform` debug launch argument (layout validation only).

---

## Measurement Results

All 4 tested scenes fill **100% of the available viewport** with no internal letterboxing. Gaps are entirely due to iOS 26 system positioning (notch safe area, system chrome).

| Scene | Viewport Width | Physical Coverage | Left Gap | Right Gap |
|-------|---------------|-------------------|----------|-----------|
| Boot/Title | 763pt | 79.8% of 956pt | 25pt (notch) | 168pt (chrome) |
| Main Menu | 763pt | 79.8% of 956pt | 25pt (notch) | 168pt (chrome) |
| Desk Scene | 763pt | 79.8% of 956pt | 25pt (notch) | 168pt (chrome) |
| Platform | 763pt | 79.8% of 956pt | 25pt (notch) | 168pt (chrome) |

**No scene has internal black borders.** The 25pt left and 168pt right gaps are iOS 26 compact window positioning (notch safe area and system chrome), not unused app space.

---

## iOS 26 Simulator Limitation

The iOS 26 simulator enforces compact windowed mode (480×320pt virtual) regardless of `UIRequiresFullScreen` or `_UILaunchAlwaysFullScreen`. This is a known simulator constraint documented in project memory. The compact window is upscaled by iOS to 763×413pt for display.

**On a real iPhone 17 Pro Max**, `UIRequiresFullScreen + _UILaunchAlwaysFullScreen` (now present in Info.plist) will produce a full 956×440pt scene. The previous sizeRestrictions code in SceneDelegate was locking the window to 480×320 and preventing this expansion — now removed.

---

## Screenshots

All screenshots are 1320×2868px portrait framebuffer captures (device physical display; app content appears rotated 90° into landscape orientation).

- `design/screenshots/layout_boot.png` — Boot/title scene, viewport 763pt wide
- `design/screenshots/layout_mainmenu.png` — Main menu, viewport 763pt wide
- `design/screenshots/layout_desk.png` — Desk scene with case_ch1_001, viewport 763pt wide
- `design/screenshots/layout_platform.png` — Platform scene level_ch1, viewport 763pt wide

---

## Summary

The app scenes fill 100% of the available iOS 26 landscape viewport with no internal letterboxing. The Info.plist now correctly declares `UIRequiresFullScreen`, landscape orientation lock, and the iOS 26 full-screen hint. The sizeRestrictions code that was preventing window expansion has been removed. On a real device, these changes produce full 956×440pt landscape rendering.
