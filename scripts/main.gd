extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 1.0
var PearlPrice: float = 1.0
var MilkPrice: float = 1.0
var player_balance: float = 100.0
var good_container = preload("res://scenes/good_container.tscn")

'''
Upgrade Stats
These stats are modified by the upgrade shop and affect gameplay in various ways
Other scripts will reference these variables to apply the effects of upgrades
'''
var ingredient_storage: int = 5
var popularity : int = 0
var supply_level : int = 0
var wait_time_increase: float = 0.0
var ingredient_level: int = 0

'''
Time Variables:
	These are used to show the time of day in AM/PM
	and the day of the week
	When the week ends, an End of Week summary screen will pop up 
	showing the player's performance and stats for the week
	and an upgrade shop
'''
var time: String = ""
var day: String = ""
var day_length: float = 60.0 #seconds per day
var time_elapsed: float = 0.0
var shop_open_hour: int = 10 #10 AM
var shop_close_hour: int = 20 #8 PM
var shop_hours: int = shop_close_hour - shop_open_hour
var days_of_week: Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
var current_day_index: int = 0
var week_is_active: bool = true
var weeks_completed: int = 0

@export var eow_scene: PackedScene


'''
This dictionary contains ingredients and data
Ingredients will be added to it after each level
'''
var game_ingredients = {
	"tea": {"quantity": tea_quantity, "Price": TeaPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage},
	"pearls": {"quantity": pearls_quantity, "Price": PearlPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage},
	"milk": {"quantity": milk_quantity, "Price": MilkPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage}
}



'''
Init: build UI, set starting state
'''
func _ready() -> void:
	create_good_containers()
	create_storage()
	
	pass

'''
Called every frame;
drives UI updates and time
'''
func _process(delta: float) -> void:
	update_good_containers()
	handle_time(delta)
	pass


### UI Creation Functions
#----------------------------------------------------------------------------------		


'''
Spawns a good_container node per ingredient;
populates labels and icons
'''
func create_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = good_container.instantiate()
		good.name = ingredient
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]
		good.get_node("Icon").texture =load("res://Icons/" + ingredient + ".jpg")
		good.get_node("Name").text = ingredient.capitalize()
		good.get_node("PriceChange").texture = load("res://PriceChangeIcons/" + game_ingredients[ingredient]["PriceChange"] + ".jpg")
		get_node("GameUI/GoodContainer").add_child(good)

'''
Builds storage label list from
game_ingredients on startup
'''
func create_storage():
	var storage_node = get_node("GameUI/Storage")
	for ingredient in game_ingredients.keys():
		var storage_item = Label.new()
		storage_item.text = ingredient.capitalize() + ": " + str(game_ingredients[ingredient]["quantity"]) + "/" + str(game_ingredients[ingredient]["Storage_Limit"])
		storage_node.add_child(storage_item)

### UI Update Functions
#----------------------------------------------------------------------------------		


'''
Refreshes price text on all
good_container nodes each frame
'''
func update_good_containers() -> void:
	for ingredient in game_ingredients.keys():
		var good = get_node("GameUI/GoodContainer/" + ingredient)
		good.get_node("Price").text = "$%.2f" % game_ingredients[ingredient]["Price"]

'''
Refreshes qty/limit text on
all storage labels
'''
func update_storage() -> void:
	var storage_node = get_node("GameUI/Storage")
	print(storage_node.get_child_count())
	for i in range(storage_node.get_child_count()):
		var storage_item = storage_node.get_child(i)
		storage_item.text = game_ingredients.keys()[i].capitalize() + ": " + str(game_ingredients[game_ingredients.keys()[i]]["quantity"]) + "/" + str(game_ingredients[game_ingredients.keys()[i]]["Storage_Limit"])

'''
Signal: player buys an ingredient
from a deal bubble
'''
func _on_bubble_clicked(ingredient: String, price: float) -> void:
	game_ingredients[ingredient]["quantity"] += 1
	player_balance -= price
	update_good_containers()
	update_storage()



### Order handling functions
#--------------------------------------------------------------------------


'''
Signal: deducts ingredients, credits balance,
reorders the queue
'''
func _on_order_fulfilled(order_number, order, price) -> void:
	# $"OrderList".happiness_score += 10
	
	
	print("Order ", order_number, " fulfilled! Order details: ", order, " Price: ", price)
	player_balance += pricei want 
	for ingredients in order.keys():
		game_ingredients[ingredients]["quantity"] -= order[ingredients]
	update_good_containers()
	update_storage()

	await get_tree().create_timer(0.1).timeout
	$"OrderList".call_deferred("_reorder_orders")

'''
Signal: penalizes happiness,
reorders the queue
'''
func _on_order_failed(order_number) -> void:
	# $"OrderList".happiness_score -= 10
	print("Order ", order_number, " failed!")
	await get_tree().create_timer(0.1).timeout
	$"OrderList".call_deferred("_reorder_orders")
	




### Time and Week handling functions
#----------------------------------------------------------------------------------
'''
Advances ingame clock each frame;
triggers end_week when Sunday ends
'''
func handle_time(delta: float) -> void:
	if not week_is_active:
		return

	time_elapsed += delta

	if time_elapsed >= day_length:
		time_elapsed -= day_length
		var next_index: int = current_day_index + 1
		if next_index >= days_of_week.size():
			end_week()
			return
		current_day_index = next_index
		day = days_of_week[current_day_index]

	var progress: float = time_elapsed / day_length
	var game_hour_float: float = shop_open_hour + progress * shop_hours
	var current_hour: int = int(game_hour_float)
	var current_minute: int = int((game_hour_float - current_hour) * 60)

	var suffix: String = "AM" if current_hour < 12 else "PM"
	var display_hour: int = current_hour if current_hour <= 12 else current_hour - 12
	time = "%d:%02d %s" % [display_hour, current_minute, suffix]
	day = days_of_week[current_day_index]
	$"GameUI/TimeTracker/clock".text = ("Day: %s  Time: %s" % [day, time])

'''
Flags week done, increments counter,
stops timers, shows EOW screen
'''
func end_week() -> void:
	week_is_active = false
	weeks_completed += 1
	_stop_timers()
	_show_eow()

'''
Stops all three spawner/logic
timers in the scene
'''
func _stop_timers() -> void:
	$"PriceCalculator/Timer".stop()
	$"bubbles/Timer".stop()
	$"OrderList/Timer".stop()

'''
Instantiates EOW scene and
adds it on top of everything
'''
func _show_eow() -> void:
	if eow_scene == null:
		push_warning("eow_scene is not assigned in the Inspector.")
		return
	var eow = eow_scene.instantiate()
	get_tree().root.add_child(eow)