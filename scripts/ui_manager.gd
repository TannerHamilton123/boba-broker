
extends Node

@onready var main = get_parent()

var good_container = preload("res://scenes/good_container.tscn")

func _ready() -> void:
	pass
	# create_good_containers()
	# create_storage()

func _process(delta: float) -> void:
	update_storage(delta)
	# update_good_containers()
	move_price_icons()

func update_storage(delta: float, fill_speed: float = 5.0) -> void:
	for ingredient in main.game_ingredients.keys():
		var storage_bar = main.get_node("GameUI/StorageBars/" + ingredient)
		var quantity = main.game_ingredients[ingredient]["quantity"]
		var limit = main.game_ingredients[ingredient]["Storage_Limit"]
		storage_bar.max_value = limit
		storage_bar.step = 0
		storage_bar.value = move_toward(storage_bar.value, float(quantity), delta * fill_speed)

func move_price_icons():
	for ingredient in main.game_ingredients.keys():
		var good_icon = get_node_or_null("../GameUI/PriceBar/icons/" + ingredient)
		if good_icon == null:
			# print("Could not find icon for ", ingredient)
			continue
		var price = main.game_ingredients[ingredient]["Price"]
		var top_of_bar = 300
		var bottom_of_bar = 0
		var new_location = (price - 1.0) / 4.0 * (top_of_bar - bottom_of_bar) + bottom_of_bar
		var inverted_location = top_of_bar - (new_location - bottom_of_bar)
		good_icon.position.y = lerp(good_icon.position.y, inverted_location, 0.01)

func show_notification(text: String, duration: float = 2.0) -> void:
	# print("Showing notification: ", text)
	var notification = main.get_node("GameUI/Notification")
	notification.text = text
	notification.modulate.a = 1.0
	notification.show()

func start_new_week():
	pass