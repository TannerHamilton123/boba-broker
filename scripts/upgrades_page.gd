extends Control

@onready var main = get_node("/root/main")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.menu_music = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_pressed() -> void:
	main.game_music = true
	print("Continue button pressed, starting next week...")
	var main = get_node("/root/main")
	queue_free()
	main.start_next_week()