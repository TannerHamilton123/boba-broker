extends Node


const MIN_PRICE = 1.0
const MAX_PRICE = 5.0
var main

func _ready() -> void:
	main = get_tree().root.get_node("main")

func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	# print("Updating prices...")
	for ingredient in main.game_ingredients.keys():
		var current_price = main.game_ingredients[ingredient]["Price"]
		# if current_price > 2.5:
		# 	main.game_ingredients[ingredient]["Price"] = randf_range(MIN_PRICE, current_price)
		# else:
		# 	main.game_ingredients[ingredient]["Price"] = randf_range(current_price, MAX_PRICE)


