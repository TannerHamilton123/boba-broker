extends Control

@onready var main = get_node("/root/main")
@onready var watch_ad_button = get_node("WatchAdButton")
@export var reward_amount: float = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if main.get_node("TimeManager").weeks_completed == 1:
		$Benny.visible = true
	else:
		$Benny.visible = false
	main.menu_music = true
	watch_ad_button.text = "Watch Ad for $%d" % int(reward_amount)
	pass # Replace with function body.


func _on_continue_pressed() -> void:
	main.game_music = true
	print("Continue button pressed, starting next week...")
	CMGApi.request_ad_break()
	queue_free()
	main.start_next_week()

'''
Rewarded ad: watch_ad_button disables immediately so the player can't
request a second ad before this one resolves. The bonus is only granted
once CMGApi confirms the ad actually completed, via reward_ad_completed.
'''
func _on_watch_ad_pressed() -> void:
	print("Watch Ad button pressed, requesting rewarded ad...")
	watch_ad_button.disabled = true
	JavaScriptBridge.eval("cmgRewardAds();", true)
	CMGApi.reward_ad_completed.connect(_on_reward_ad_completed, CONNECT_ONE_SHOT)
	CMGApi.request_rewarded_ad()

func _on_reward_ad_completed() -> void:
	main.player_balance += reward_amount
