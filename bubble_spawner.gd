extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass



func spawn_bubble() -> void:
	var bubble_scene = preload("res://deal_bubble.tscn")
	var bubble_instance = bubble_scene.instantiate()
	bubble_instance.position = Vector2(randf_range(200, 600), 600)
	get_parent().add_child(bubble_instance)

	var ingredient = ["tea", "pearls", "milk"].pick_random()
	var price: float = 1.00
	match ingredient:
		"tea":
			price = get_parent().TeaPrice
		"pearls":
			price = get_parent().PearlPrice
		"milk":
			price = get_parent().MilkPrice

	bubble_instance.deal_type(ingredient, price)
	


func _on_timer_timeout() -> void:
	spawn_bubble()
	pass # Replace with function body.
