extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 1.0
var PearlPrice: float = 1.0
var MilkPrice: float = 1.0
var player_balance: float = 100
var good_container = preload("res://good_container.tscn")
var game_ingredients = {
	"tea": {"quantity": tea_quantity, "Price": TeaPrice, "PriceChange": "stable"},
	"pearls": {"quantity": pearls_quantity, "Price": PearlPrice, "PriceChange": "stable"},
	"milk": {"quantity": milk_quantity, "Price": MilkPrice, "PriceChange": "stable"}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_good_containers()
	# update_ui()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_good_containers()
	pass
	



func create_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = good_container.instantiate()
		good.name = ingredient
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]
		good.get_node("Icon").texture =load("res://Icons/" + ingredient + ".jpg")
		good.get_node("Name").text = ingredient.capitalize()
		good.get_node("PriceChange").texture = load("res://PriceChangeIcons/" + game_ingredients[ingredient]["PriceChange"] + ".jpg")
		get_node("Control/GoodContainer").add_child(good)

func update_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = get_node("Control/GoodContainer/" + ingredient)
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]
		# good.get_node("PriceChange").texture = get_node("PriceChangeIcons/" + game_ingredients[ingredient]["PriceChange"])



	
	# if player_balance <= 0:
	# 	print("game over")
	# 	$GameOver.visible = true

	# pass

# func _on_bubble_clicked(ingredient: String, price: float) -> void:
# 	match ingredient:
# 		"tea":
# 			tea_quantity += 1
# 		"pearls":
# 			pearls_quantity += 1
# 		"milk":
# 			milk_quantity += 1
# 	player_balance -= price
# 	update_ui()

# func update_ui() -> void:
# 	$"Boba_Crafting/tea/tea_quantity".text = " tea: " + str(tea_quantity)
# 	$"Boba_Crafting/pearls/pearl_quantity".text = "Pearls: " + str(pearls_quantity)
# 	$"Boba_Crafting/milk/milk_quantity".text = "Milk: " + str(milk_quantity)



# func _on_Ingredient_drag_data_received(position: Vector2, data: Variant) -> void:
# 	print("Received drag data: ", data, " at position: ", position)
# 	if data == "tea":
# 		tea_quantity += 1
# 	elif data == "pearls":
# 		pearls_quantity += 1
# 	elif data == "milk":
# 		milk_quantity += 1
# 	update_ui()
