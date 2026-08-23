extends Node

'''
Single point of contact for the CoolMathGames JS bridge:
game-event postMessages, and the two ad-break entry points
(cmgAdBreak for midroll, cmgRewardAds for rewarded).
Requires cmg-ads.js to be loaded via the Web export's head_include.
'''

signal reward_ad_completed

@export var ready_check_max_attempts: int = 20
@export var ready_check_interval_sec: float = 0.25

var _pending_reward: bool = false
var _callback_adbreak_start = JavaScriptBridge.create_callback(_on_adbreak_start)
var _callback_adbreak_complete = JavaScriptBridge.create_callback(_on_adbreak_complete)

func _ready() -> void:
	if OS.get_name() == "HTML5":
		JavaScriptBridge.get_interface("document").addEventListener("adBreakStart", _callback_adbreak_start)
		JavaScriptBridge.get_interface("document").addEventListener("adBreakComplete", _callback_adbreak_complete)


func send_game_event(event_type: String, level: int) -> void:
	print("send_game_event called with event_type =", event_type, " and level =", level)
	if OS.get_name() != "HTML5":
		return
	var payload := {"cm_game_event": true, "cm_game_evt": event_type, "cm_game_lvl": level}
	JavaScriptBridge.eval("window.parent.postMessage(%s, '*');" % JSON.stringify(payload), true)


func request_ad_break() -> void:
	print("request_ad_break called")
	JavaScriptBridge.eval("cmgAdBreak();", true)
	if OS.get_name() != "HTML5":
		return
	_call_when_defined("cmgAdBreak", "request_ad_break", ready_check_max_attempts)


func request_rewarded_ad() -> void:
	print("requesting_rewarded_ad called")
	JavaScriptBridge.eval("cmgRewardAds();", true)
	if OS.get_name() != "HTML5":
		return
	_pending_reward = true
	_call_when_defined("cmgRewardAds", "request_rewarded_ad", ready_check_max_attempts)


func _call_when_defined(js_function_name: String, caller_label: String, attempts_left: int) -> void:
	var is_defined: bool = JavaScriptBridge.eval("typeof %s === 'function'" % js_function_name, true)
	if is_defined:
		_eval_ad_call(js_function_name, caller_label)
		return
	if attempts_left <= 0:
		JavaScriptBridge.get_interface("console").error(
			"CMGApi: %s() gave up waiting for %s to be defined after %d attempts" % [caller_label, js_function_name, ready_check_max_attempts]
		)
		return
	print("CMGApi: %s not yet defined, retrying (%d attempts left)" % [js_function_name, attempts_left])
	await get_tree().create_timer(ready_check_interval_sec).timeout
	_call_when_defined(js_function_name, caller_label, attempts_left - 1)


func _eval_ad_call(js_function_name: String, caller_label: String) -> void:
	var js := """
		try {
			console.log('CMGApi: %s(), typeof %s =', typeof %s);
			if (typeof %s === 'function') {
				%s();
			} else {
				console.error('CMGApi: %s() failed - %s is not defined');
			}
		} catch (e) {
			console.error('CMGApi: %s() threw an error calling %s():', e);
		}
	""" % [caller_label, js_function_name, js_function_name, js_function_name, js_function_name, caller_label, js_function_name, caller_label, js_function_name]
	JavaScriptBridge.eval(js, true)


func _on_adbreak_start(_args) -> void:
	print("_on_adbreak_start called")
	JavaScriptBridge.get_interface("console").log("AdBreak Started")
	get_tree().paused = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func _on_adbreak_complete(_args) -> void:
	print("_on_adbreak_complete called")
	JavaScriptBridge.get_interface("console").log("AdBreak Completed")
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	if _pending_reward:
		_pending_reward = false
		print("Reward ad completed, emitting signal")
		reward_ad_completed.emit()
