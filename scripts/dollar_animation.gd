extends Node2D

func _ready() -> void:
	trigger()
	pass # Replace with function body.


func trigger() -> void:
	$AnimationPlayer.play("fulfill")
	await $AnimationPlayer.animation_finished
	queue_free()
