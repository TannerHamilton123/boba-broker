extends Node

@onready var main = get_parent()
@onready var ui_manager = get_parent().get_node("UIManager")

@onready var summary_manager = get_node("/root/main/SummaryManager")



'''
Receives a fulfilled order; stores it and
accumulates per-ingredient revenue split evenly by unit count
'''
func _on_order_fulfilled(order: Dictionary, price: float) -> void:

	summary_manager.fulfilled_orders.append({ "order": order, "price": price })
	summary_manager._accumulate_ingredient_revenue(order, price)

	print("Order fulfilled! Details: ", order, " Price: ", price)
	main.player_balance += price
	for ingredient in order.keys():
		main.game_ingredients[ingredient]["quantity"] -= order[ingredient]
	# ui_manager.update_good_containers()
	ui_manager.update_storage()
	await get_tree().create_timer(0.1).timeout
	main.get_node("OrderList").call_deferred("_reorder_orders")



'''
Logs failed order and reorders the queue
'''
func _on_order_failed(order_number) -> void:
	print("Order ", order_number, " failed!")
	await get_tree().create_timer(0.1).timeout
	main.get_node("OrderList").call_deferred("_reorder_orders")


'''
Signal: player buys an ingredient from a deal bubble
'''
func _on_bubble_clicked(ingredient: String, price: float) -> void:
	main.game_ingredients[ingredient]["quantity"] += 1
	summary_manager._accumulate_ingredient_cost(ingredient, price)
	main.player_balance -= price
	# ui_manager.update_good_containers()
	ui_manager.update_storage()
