extends Control
var fade_away: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("start")
	await $AnimationPlayer.animation_finished
	$IngredientSpawner/Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_away:
		$menu_music.volume_db -= delta * 20
	pass


func _on_play_button_pressed() -> void:
	$AnimationPlayer.play("transition")
	fade_away = true
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	pass # Replace with function body.
