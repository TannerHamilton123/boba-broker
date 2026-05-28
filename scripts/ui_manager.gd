
extends Node

@onready var main = get_parent()

var good_container = preload("res://scenes/good_container.tscn")

func _ready() -> void:
	# create_good_containers()
	create_storage()

func _process(_delta: float) -> void:
	# update_good_containers()
	move_price_icons()

# func create_good_containers() -> void:
# 	for ingredient in main.game_ingredients.keys():
# 		var good = good_container.instantiate()
# 		good.name = ingredient
# 		good.get_node("Price").text = "$%.2f" % main.game_ingredients[ingredient]["Price"]
# 		good.get_node("Icon").texture = load("res://Icons/" + ingredient + ".jpg")
# 		good.get_node("Name").text = ingredient.capitalize()
# 		good.get_node("PriceChange").texture = load("res://PriceChangeIcons/" + main.game_ingredients[ingredient]["PriceChange"] + ".jpg")


func create_storage() -> void:
	var storage_node = main.get_node("GameUI/Storage")
	for ingredient in main.game_ingredients.keys():
		var storage_item = Label.new()
		storage_item.text = ingredient.capitalize() + ": " + str(main.game_ingredients[ingredient]["quantity"]) + "/" + str(main.game_ingredients[ingredient]["Storage_Limit"])
		storage_node.add_child(storage_item)

# func update_good_containers() -> void:
# 	for ingredient in main.game_ingredients.keys():
# 		var good = main.get_node("GameUI/GoodContainer/" + ingredient)
# 		good.get_node("Price").text = "$%.2f" % main.game_ingredients[ingredient]["Price"]

func update_storage() -> void:
	var storage_node = main.get_node("GameUI/Storage")
	for i in range(storage_node.get_child_count()):
		var key = main.game_ingredients.keys()[i]
		storage_node.get_child(i).text = key.capitalize() + ": " + str(main.game_ingredients[key]["quantity"]) + "/" + str(main.game_ingredients[key]["Storage_Limit"])
	for ingredient in main.game_ingredients.keys():
		var storage_bar = main.get_node("GameUI/StorageBars/" + ingredient)
		var quantity = main.game_ingredients[ingredient]["quantity"]
		var limit = main.game_ingredients[ingredient]["Storage_Limit"]
		storage_bar.value = quantity
		storage_bar.max_value = limit

func move_price_icons():
	for ingredient in main.game_ingredients.keys():
		var good_icon = get_node_or_null("../GameUI/PriceBar/icons/" + ingredient)
		if good_icon == null:
			print("Could not find icon for ", ingredient)
			continue
		var price = main.game_ingredients[ingredient]["Price"]
		var top_of_bar = 300
		var bottom_of_bar = 0
		var new_location = (price - 1.0) / 4.0 * (top_of_bar - bottom_of_bar) + bottom_of_bar
		var inverted_location = top_of_bar - (new_location - bottom_of_bar)
		good_icon.position.y = lerp(good_icon.position.y, inverted_location, 0.01)
