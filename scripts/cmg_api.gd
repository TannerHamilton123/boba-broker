extends Node

'''
Single point of contact for the CoolMathGames JS bridge:
game-event postMessages, and the two ad-break entry points
(cmgAdBreak for midroll, cmgRewardAds for rewarded).
Requires cmg-ads.js to be loaded via the Web export's head_include.
'''

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
	JavaScriptBridge.get_interface("console").log("AdBreak Started")
	get_tree().paused = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func _on_adbreak_complete(_args) -> void:
	JavaScriptBridge.get_interface("console").log("AdBreak Completed")
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	if _pending_reward:
		_pending_reward = false
		reward_ad_completed.emit()
