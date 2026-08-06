extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("new_animation")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
