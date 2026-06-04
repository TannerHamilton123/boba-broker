extends Node
var bubble_scene = preload("res://scenes/deal_bubble.tscn")
var bag = []
@onready var main = get_node("/root/main")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_bag_of_ingredients()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	

	
	pass



func spawn_bubble() -> void:
	var game_ingredients = main.game_ingredients
	
	var bubble_instance = bubble_scene.instantiate()

	bubble_instance.position = Vector2(randf_range(200, 600), randf_range(550,600))

	get_parent().get_node("Bubbles").add_child(bubble_instance)
	var bubble_ingredient = choose_ingredient()
	var price: float = game_ingredients[bubble_ingredient]["Price"]

	bubble_instance.deal_type(bubble_ingredient, price)
	bubble_instance.connect("bubble_clicked", get_node("/root/main/OrderManager")._on_bubble_clicked)
	bubble_instance.connect("No_Storage", main._on_no_storage)


func _on_timer_timeout() -> void:
	$Timer.wait_time = randf_range(0.5,1.5) - main.supply_level * 0.1
	$Timer.start()
	spawn_bubble()
	pass # Replace with function body.

func choose_ingredient() -> String:
	if bag.size() == 0:
		make_bag_of_ingredients()
		return choose_ingredient()
	print(bag)
	return bag.pop_front() # Remove the first ingredient from the bag and return it


func make_bag_of_ingredients() -> Array:
	var game_ingredients = main.game_ingredients
	bag = []
	for ingredient in game_ingredients.keys():
		for i in range(int(game_ingredients[ingredient]["Spawn_Probability"] * 10)): # Add multiple copies of each ingredient based on spawn probability
			bag.append(ingredient)
	bag.shuffle()
	return bag