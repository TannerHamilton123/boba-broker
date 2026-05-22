extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 1.0
var PearlPrice: float = 1.0
var MilkPrice: float = 1.0
var player_balance: float = 100.0
var good_container = preload("res://scenes/good_container.tscn")


#This dictionary contains ingredients and data
#Ingredients will be added to it after each level
var game_ingredients = {
	"tea": {"quantity": tea_quantity, "Price": TeaPrice, "PriceChange": "stable","Storage_Limit": 5},
	"pearls": {"quantity": pearls_quantity, "Price": PearlPrice, "PriceChange": "stable","Storage_Limit": 5},
	"milk": {"quantity": milk_quantity, "Price": MilkPrice, "PriceChange": "stable","Storage_Limit": 5}
}



func _ready() -> void:
	create_good_containers()
	create_storage()
	
	pass

func _process(_delta: float) -> void:
	update_good_containers()
	pass
	

### UI Creation Functions
#----------------------------------------------------------------------------------		


func create_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = good_container.instantiate()
		good.name = ingredient
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]
		good.get_node("Icon").texture =load("res://Icons/" + ingredient + ".jpg")
		good.get_node("Name").text = ingredient.capitalize()
		good.get_node("PriceChange").texture = load("res://PriceChangeIcons/" + game_ingredients[ingredient]["PriceChange"] + ".jpg")
		get_node("Control/GoodContainer").add_child(good)

func create_storage():
	var storage_node = get_node("Control/Storage")
	for ingredient in game_ingredients.keys():
		var storage_item = Label.new()
		storage_item.text = ingredient.capitalize() + ": " + str(game_ingredients[ingredient]["quantity"]) + "/" + str(game_ingredients[ingredient]["Storage_Limit"])
		storage_node.add_child(storage_item)

### UI Update Functions
#----------------------------------------------------------------------------------		


func update_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = get_node("Control/GoodContainer/" + ingredient)
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]

func update_storage() -> void:
	var storage_node = get_node("Control/Storage")
	print(storage_node.get_child_count())
	for i in range(storage_node.get_child_count()):
		var storage_item = storage_node.get_child(i)
		storage_item.text = game_ingredients.keys()[i].capitalize() + ": " + str(game_ingredients[game_ingredients.keys()[i]]["quantity"]) + "/" + str(game_ingredients[game_ingredients.keys()[i]]["Storage_Limit"])

func _on_bubble_clicked(ingredient: String, price: float) -> void:
	game_ingredients[ingredient]["quantity"] += 1
	player_balance -= price
	update_good_containers()
	update_storage()






### Order handling functions

func _on_order_fulfilled(order_number, order, price) -> void:
	# $"OrderList".happiness_score += 10
	
	
	print("Order ", order_number, " fulfilled! Order details: ", order, " Price: ", price)
	player_balance += price
	for ingredients in order.keys():
		game_ingredients[ingredients]["quantity"] -= order[ingredients]
	update_good_containers()
	update_storage()
	await get_tree().create_timer(0.1).timeout
	$"OrderList".call_deferred("_reorder_orders")

func _on_order_failed(order_number) -> void:
	# $"OrderList".happiness_score -= 10
	await get_tree().create_timer(0.1).timeout
	$"OrderList".call_deferred("_reorder_orders")
	print("Order ", order_number, " failed!")