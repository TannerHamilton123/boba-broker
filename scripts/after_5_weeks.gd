extends Control
var fade_away: bool = false
var total_profit: float = 100.00
var current_profit_value:= 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_profit = Global.week_5_profit #for a test
	$AnimationPlayer.play("start")
	print("Playing animation")
	await $AnimationPlayer.animation_finished
	print("animation finished")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
 
	var score_label = get_node("Summary/profit")
	if current_profit_value < total_profit:
		current_profit_value += delta * 100
		if current_profit_value > total_profit:
			current_profit_value = total_profit
			#$AnimationPlayer.play("profit_count_finished")
		score_label.text = "$%.2f" % current_profit_value
	if fade_away:
		$menu_music.volume_db -= delta * 20
	# print("score is " + score_label.text)
	# print("total profit is " + str(total_profit))


func _on_play_button_pressed() -> void:
	$AnimationPlayer.play("transition")
	fade_away = true
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
	pass # Replace with function body.
