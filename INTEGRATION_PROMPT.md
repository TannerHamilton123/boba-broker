# Prompt: re-integrate CoolMathGames features after the July rewind

Paste this whole file's content into a new Claude Code conversation once you're on
the rewound branch. It gives Claude everything needed to re-integrate the features
that were reverted, without re-deriving them from scratch.

---

## Context

This repo was rewound to commit `7a5c48f` ("Slowed down buttons... Updated upgrade
buttons to show as unaffordable...", 2026-07-29) to drop some later changes I didn't
want. I still need these 4 things re-integrated:

1. **Save/load system** — so progress persists across browser sessions (CoolMathGames
   requires this: "progress saves to local storage or indexed DB").
2. **Domain verification** — site-lock so the exported HTML5 build only runs on
   CoolMathGames domains (`DomainValidator` node/script).
3. **CMG API integration** — the `cm_game_event` postMessage calls (start/replay) and
   the JS bridge for ad breaks (`cmgAdBreak`, `cmgRewardAds`, `adBreakStart`/
   `adBreakComplete` listeners).
4. **Ads** — a midroll ad break triggered when the player continues to the next week,
   plus a rewarded "watch ad" button on the upgrades screen that grants bonus cash.

**Button affordability is already done** in this snapshot
(`scripts/upgrade_button.gd` already greys out/disables upgrades the player can't
afford) — just verify it still works, don't reimplement it.

## IMPORTANT — check git history first, it's probably still there

This work was already built once on this same repo, on the `main` branch (and/or
`origin/main`). Before writing any new code:

```
git branch -a
git log --oneline main | head -20
```

If `main` (or `origin/main`) still contains commits past `7a5c48f`, **use it as the
source of truth** instead of reimplementing from the description below — it's the
real, tested code, including bugfixes made after the initial implementation (there
were a couple of subtle ordering bugs around when the save actually gets written —
see "gotchas" section below, already fixed on `main`).

Useful commands:
```
git diff 7a5c48f main -- scripts/main.gd
git diff 7a5c48f main -- scripts/time_manager.gd
git diff 7a5c48f main -- scripts/upgrades_page.gd
git diff 7a5c48f main -- scripts/titlescreen.gd
git show main:scripts/save_manager.gd
git show main:scenes/domain_validator.gd
git show main:scripts/cmg_api.gd
git show main:cmg_splash_screen.gd
git show main:scenes/CMGSplashScreen.tscn
git show main:project.godot
git show main:export_presets.cfg
git show main:CMGCommunication.md    # the actual CMG licensing email + API spec
```

**Don't blindly merge all of `main`** — it also contains unrelated changes I don't
want ported here: ingredient price "Premium" mechanic, funnier event names in
`event_manager.gd`, EOW/upgrades screen color tweaks, a splash-screen rebrand image,
and some `.gitignore`/doc cleanup. Cherry-pick only the touch points listed below.

If `main` is gone (force-pushed over, deleted, whatever) — fall back to the
plain-English spec and full file contents in the sections below, which are
self-contained.

---

## File manifest

New files to (re)create:
- `scripts/save_manager.gd` — autoload, JSON read/write to `user://savegame.json`
- `scenes/domain_validator.gd` — plain `Node` script, added as a `DomainValidator`
  child of the main scene's root node
- `scripts/cmg_api.gd` — autoload, wraps all the CMG JS bridge calls
- `cmg_splash_screen.gd` + `scenes/CMGSplashScreen.tscn` — new main scene: plays a
  splash animation showing `assets/CoolmathGames-800x600.png`, then transitions to
  `titlescreen.tscn`
- `assets/CoolmathGames-800x600.png` — the splash image CMG provided (attached to
  their licensing email — if it's gone, ask me for it)
- `CMGCommunication.md` — worth copying over even though it's just docs, it's the
  actual licensing email + the Godot 3.x integration doc CMG sent, useful reference

Modified files:
- `project.godot` — add `SaveManager` and `CMGApi` to `[autoload]`; change
  `run/main_scene` to point at `CMGSplashScreen.tscn`
- `export_presets.cfg` — set `html/head_include` to load jQuery + `cmg-ads.js`
  (see snippet below)
- `scenes/main.tscn` — add `DomainValidator` node as child of root
- `scripts/main.gd` — domain check at top of `_ready()`, save/load wiring,
  `get_save_data()` / `apply_save_data()`, clear save on game-over and on restart
- `scripts/time_manager.gd` — send `"start"` game event in `start_next_week()`;
  don't auto-start a week in `_ready()` if a save already exists
- `scripts/upgrades_page.gd` — `CMGApi.request_ad_break()` on "Continue", new
  "Watch Ad" button wired to `CMGApi.request_rewarded_ad()` / `reward_ad_completed`
- `scripts/titlescreen.gd` + `scenes/titlescreen.tscn` — "CONTINUE" vs "PLAY" button
  text based on `SaveManager.has_save()`, new `RestartButton` that clears the save

---

## Reference implementations (fallback if `main` branch is unavailable)

### `scripts/save_manager.gd` (new autoload)

```gdscript
extends Node

const SAVE_PATH: String = "user://savegame.json"

func has_save(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)

func save_game(data: Dictionary, path: String = SAVE_PATH) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not open %s for writing (error %d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
	file.close()
	_sync_web_filesystem()

func load_game(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func clear_save(path: String = SAVE_PATH) -> void:
	if FileAccess.file_exists(path):
		var dir := DirAccess.open(path.get_base_dir())
		if dir == null:
			push_warning("SaveManager: could not open %s for deletion (error %d)" % [path.get_base_dir(), DirAccess.get_open_error()])
		else:
			var err := dir.remove(path.get_file())
			if err != OK:
				push_warning("SaveManager: failed to delete %s (error %d)" % [path, err])
	_sync_web_filesystem()

# On the Web export user:// lives in an in-memory FS that Godot mirrors to
# IndexedDB. Writes only persist across a browser session if that mirror is
# flushed, so force a sync right after any write/delete.
func _sync_web_filesystem() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (typeof FS !== 'undefined') { FS.syncfs(false, function(err) {}); }")
```

Register as autoload in `project.godot`: `SaveManager="*res://scripts/save_manager.gd"`.

**What to save** (see `get_save_data()`/`apply_save_data()` in `main.gd` on `main`):
`player_balance`, `ingredient_storage`, `popularity`, `supply_level`,
`wait_time_increase`, `ingredient_level`, `weeks_completed`, `upgrade_levels`
(from `UpgradeManager`), and current ingredient quantities. In-week state (live
orders, bubbles) is deliberately left out — cheap to regenerate, resets every week
anyway.

**Gotcha already hit and fixed once**: only call `SaveManager.save_game(...)` from
the *player-driven* "continue to next week" action (`main.gd`'s `start_next_week()`
wrapper, called from the upgrades page's Continue button) — not from
`TimeManager.start_next_week()` itself, since that function is *also* called during
bootstrap (`TimeManager._ready()` when there's no save yet) and on resume (`main.gd`
`_ready()`'s else-branch). If you save from inside `TimeManager.start_next_week()`,
a brand-new game's very first `_ready()` bootstrap call writes a save file before
`main.gd`'s own `_ready()` gets to check `SaveManager.load_game().is_empty()` —
child nodes ready before their parent — so it wrongly thinks a save already exists
and skips the tutorial. Keep the actual `save_game()` call in `main.gd`:

```gdscript
func start_next_week() -> void:
	$TimeManager.start_next_week()
	SaveManager.save_game(get_save_data())
```

and leave `TimeManager._ready()` as `if not SaveManager.has_save(): start_next_week()`
with no save call inside `TimeManager.start_next_week()` itself.

Also clear the save (`SaveManager.clear_save()`) on game over and on the
titlescreen's restart button, and check `SaveManager.has_save()` in
`titlescreen.gd` to swap "PLAY" → "CONTINUE" and show a restart button.

### `scenes/domain_validator.gd` (new, attach to a `DomainValidator` node under
the main scene's root)

```gdscript
extends Node

var valid_domains = [
	"www.coolmathgames.com",
	"edit.coolmathgames.com",
	"stage.coolmathgames.com",
	"stage-edit.coolmathgames.com",
	"dev.coolmathgames.com",
	"m.coolmathgames.com",
	"www.coolmath-games.com",
	"edit.coolmath-games.com",
	"dev.coolmath-games.com",
	"m.coolmath-games.com"
]

func is_valid():
	if OS.is_debug_build():
		return true
	if not OS.get_name()=="HTML5":
		return true
	return valid_domains.has(get_domain())

func get_domain():
	return str(JavaScriptBridge.eval("document.location.host"))
```

At the very top of `main.gd`'s `_ready()`:
```gdscript
if not $DomainValidator.is_valid():
	get_tree().quit()
	return
```

### `scripts/cmg_api.gd` (new autoload)

```gdscript
extends Node

# Single point of contact for the CoolMathGames JS bridge: game-event
# postMessages, and the two ad-break entry points (cmgAdBreak for midroll,
# cmgRewardAds for rewarded). Requires cmg-ads.js loaded via the Web export's
# head_include.

signal reward_ad_completed

var _pending_reward: bool = false
var _callback_adbreak_start = JavaScriptBridge.create_callback(_on_adbreak_start)
var _callback_adbreak_complete = JavaScriptBridge.create_callback(_on_adbreak_complete)

func _ready() -> void:
	if OS.get_name() == "HTML5":
		JavaScriptBridge.get_interface("document").addEventListener("adBreakStart", _callback_adbreak_start)
		JavaScriptBridge.get_interface("document").addEventListener("adBreakComplete", _callback_adbreak_complete)

func send_game_event(event_type: String, level: int) -> void:
	if OS.get_name() != "HTML5":
		return
	var payload := {"cm_game_event": true, "cm_game_evt": event_type, "cm_game_lvl": level}
	JavaScriptBridge.eval("window.parent.postMessage(%s, '*');" % JSON.stringify(payload), true)

func request_ad_break() -> void:
	if OS.get_name() != "HTML5":
		return
	JavaScriptBridge.eval("if (typeof cmgAdBreak === 'function') { cmgAdBreak(); }", true)

func request_rewarded_ad() -> void:
	if OS.get_name() != "HTML5":
		return
	_pending_reward = true
	JavaScriptBridge.eval("if (typeof cmgRewardAds === 'function') { cmgRewardAds(); }", true)

func _on_adbreak_start(_args) -> void:
	get_tree().paused = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func _on_adbreak_complete(_args) -> void:
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	if _pending_reward:
		_pending_reward = false
		reward_ad_completed.emit()
```

Register as autoload: `CMGApi="*res://scripts/cmg_api.gd"`.

Call sites:
- `time_manager.gd`'s `start_next_week()`: `CMGApi.send_game_event("start", weeks_completed + 1)`
- `main.gd`'s `_on_restart_pressed()`: `CMGApi.send_game_event("replay", 1)`
- `upgrades_page.gd`'s Continue button: `CMGApi.request_ad_break()` (midroll,
  right when the player moves to the next week)
- `upgrades_page.gd`: new "Watch Ad" button — `CMGApi.request_rewarded_ad()` on
  press, `CMGApi.reward_ad_completed` (connect one-shot) grants a cash bonus
  (`main.player_balance += reward_amount`, `reward_amount` was an `@export`, e.g. $10)

### Export settings

`export_presets.cfg`, under the HTML5 preset:
```
html/head_include="<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js\"></script>
<script type=\"text/javascript\" src=\"https://www.coolmathgames.com/sites/default/files/cmg-ads.js\"></script>
"
```

### Splash screen

`run/main_scene` in `project.godot` should point at a new `CMGSplashScreen.tscn`
(CMG's rule: show their splash on load, don't make it clickable, our logos can be
before/after it) which plays an animation then does
`get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")`. Pull the actual
`.tscn` from `main` if at all possible (`git show main:scenes/CMGSplashScreen.tscn`)
— it's easier than hand-authoring a Godot scene resource from a text description.

---

## Suggested order of work

1. Confirm `main`/`origin/main` still has the history (`git branch -a`). If so, pull
   files directly with `git show main:<path>` rather than retyping from this doc.
2. `save_manager.gd` + autoload registration — get save/load working and tested
   standalone first (it's the least JS-dependent piece).
3. `domain_validator.gd` + main scene wiring — low risk, `OS.is_debug_build()`
   makes it a no-op in the editor.
4. `cmg_api.gd` + autoload — game events and ad-break plumbing. All calls are
   HTML5-only guarded, so safe to add without a web export to test against.
5. Wire the save/domain/API calls into `main.gd`, `time_manager.gd`,
   `upgrades_page.gd`, `titlescreen.gd` per the file manifest above — mind the
   save-timing gotcha.
6. Splash screen scene + `project.godot` main_scene swap — do this last since it
   changes the game's entry point and makes manual testing slightly more annoying
   (extra screen to click through each run).
7. Re-verify button affordability (`upgrade_button.gd`) still greys out correctly
   after all the above — it shouldn't need changes, just a smoke test.
