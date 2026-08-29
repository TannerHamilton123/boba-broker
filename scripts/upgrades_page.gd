extends Control

@onready var main = get_node("/root/main")
@onready var watch_ad_button = get_node("WatchAdButton")
@onready var continue_button = get_node("Continue")
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


'''
Continue button waits for the ad break to actually finish (CMGApi
pauses the tree and mutes audio while it plays) before switching
music and starting the next week, so gameplay doesn't run behind
the ad overlay.
'''
func _on_continue_pressed() -> void:
	print("Continue button pressed, requesting ad break...")
	continue_button.disabled = true
	CMGApi.ad_break_completed.connect(_on_ad_break_completed, CONNECT_ONE_SHOT)
	CMGApi.request_ad_break()

func _on_ad_break_completed() -> void:
	main.game_music = true
	print("Ad break complete, starting next week...")
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
	CMGApi.reward_ad_completed.connect(_on_reward_ad_completed, CONNECT_ONE_SHOT)
	CMGApi.request_rewarded_ad()

func _on_reward_ad_completed() -> void:
	main.player_balance += reward_amount
