extends Node
var bubble_scene = preload("res://deal_bubble.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	

	
	pass



func spawn_bubble() -> void:
	var game_ingredients = get_node("/root/main").game_ingredients
	
	var bubble_instance = bubble_scene.instantiate()

	bubble_instance.position = Vector2(randf_range(200, 600), 600)

	get_parent().add_child(bubble_instance)
	var bubble_ingredient = game_ingredients.keys()[randi() % game_ingredients.size()]
	var price: float = game_ingredients[bubble_ingredient]["Price"]

	bubble_instance.deal_type(bubble_ingredient, price)
	bubble_instance.connect("bubble_clicked", get_node("/root/main")._on_bubble_clicked)


func _on_timer_timeout() -> void:
	spawn_bubble()
	pass # Replace with function body.
