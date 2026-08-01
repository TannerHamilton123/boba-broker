# CoolMathGames Licensing Todo

Source: `scripts/CMGCommunication.md` (email from Antonia, 7/28/2026 + CMG instructions doc).
Status notes below reflect a scan of the current project as of this writing — verify before checking off.

## Must-fix (blocking / explicitly required)

- [ ] **Add CMG splash screen** on game load (PNG attached in their email — need to request/save it into the project). Not clickable. Can show before or after our own logos.
- [ ] **Add CMG API integration**
  - [ ] Include `cmg-ads.js` (and jQuery if not already bundled) in the exported `index.html` footer — set via `html/head_include` or a custom HTML shell in `export_presets.cfg` (currently both empty).
  - [ ] Fire `cm_game_evt: 'start'` postMessage on Play press and on each new level/week start.
  - [ ] Fire `cm_game_evt: 'replay'` postMessage on restart.
  - [ ] Add `adBreakStart` / `adBreakComplete` JS listeners; wire them to pause/resume game + sound (will need a JS↔GDScript bridge via `JavaScriptBridge`).
  - [ ] Decide + tell Antonia: midroll ads, rewarded ads, or no ads — call `cmgAdBreak()` / `cmgRewardAds()` at natural break points (e.g. after a week ends, before next week starts).


## Instructions doc — additional requirements

- [ ] Set tab title to `"Boba Broker – Play it now at CoolmathGames.com"` (or final game name) — needs to be set in the exported `index.html` `<title>`.
- [ ] Send CMG a **square image** (≥200×200, JPEG/PNG) featuring a key game element/character.
- [ ] Send CMG a **game logo, transparent background PNG**, medium-to-hi-res.
- [ ] **Optimize file size** — target under 50MB export. Check current Web export size once built.


- [ ] **Framerate independence (60Hz vs 120/144/165Hz)** — most movement/timers use `delta` already (good sign, e.g. `time_manager.gd`), but audit any `_process`/`_physics_process` code for frame-count-based logic instead of delta-based.

- [ ] **Fix audio autoplay blocking (Safari/Chrome).** Several scenes have `autoplay = true` on sound nodes (`titlescreen.tscn`, `sound.tscn`, `after_5_weeks.tscn`). Per CMG's instructions, add a play button the player presses before any sound tries to play, so autoplay-blocking browsers don't silently break audio.
- [ ] **Progress must save to localStorage/IndexedDB** so players can resume in the same browser — `save_manager.gd` already writes to `user://` and calls `JavaScriptBridge` `FS.syncfs` on web export. Looks implemented — verify it actually round-trips correctly in an exported web build (not just desktop).
- [ ] Mobile web (only if targeting mobile): remove "Add to Home Screen" prompt on Android if present (none found); ensure on-screen touch controls show under Safari/iPadOS via `ontouchend`/`userAgent` check — likely N/A if this is a mouse-only game, confirm with Antonia whether mobile support is expected.

## After all changes

- [ ] Export Web build, test across browsers (Chrome, Firefox, Safari) — especially the ad events and audio-unlock behavior.
- [ ] Zip the exported game and send to Antonia for testing on CMG's site.
- [ ] Reply to Antonia with a licensing price quote for the non-exclusive license.
