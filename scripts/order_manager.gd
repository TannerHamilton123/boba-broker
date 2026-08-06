extends Node

const ORDER_FULFILLED_HAPPINESS_GAIN = 2
const ORDER_FAILED_HAPPINESS_PENALTY = 10.0

@onready var main = get_parent()
@onready var ui_manager = get_parent().get_node("UIManager")
@onready var order_list = get_parent().get_node("OrderList")
@onready var summary_manager = get_node("/root/main/SummaryManager")
signal storage_full(ingredient: String)


'''
Receives a fulfilled order; stores it and
accumulates per-ingredient revenue split evenly by unit count
'''
func _on_order_fulfilled(order: Dictionary, price: float) -> void:
	order_list.happiness_score += ORDER_FULFILLED_HAPPINESS_GAIN

	main.get_node("sound/casino").play()
	summary_manager.week_revenue += price

	summary_manager.fulfilled_orders.append({ "order": order, "price": price })
	summary_manager._accumulate_ingredient_revenue(order, price)

	main.player_balance += price
	for ingredient in order.keys():
		main.game_ingredients[ingredient]["quantity"] -= order[ingredient]
	# ui_manager.update_good_containers()
	# ui_manager.update_storage()
	await get_tree().create_timer(0.1).timeout
	main.get_node("OrderList").call_deferred("_reorder_orders")



'''
Logs failed order and reorders the queue
'''
func _on_order_failed() -> void:
	order_list.happiness_score -= ORDER_FAILED_HAPPINESS_PENALTY
	await get_tree().create_timer(0.1).timeout
	main.get_node("OrderList").call_deferred("_reorder_orders")


'''
Signal: player buys an ingredient from a deal bubble
'''
func _on_bubble_clicked(ingredient: String, price: float) -> void:
	if main.game_ingredients[ingredient]["quantity"] < main.ingredient_storage:

		main.game_ingredients[ingredient]["quantity"] += 1
		summary_manager._accumulate_ingredient_cost(ingredient, price)
		summary_manager.week_cost += price
		main.player_balance -= price
		# ui_manager.update_good_containers()
		# ui_manager.update_storage()
	else:
		emit_signal("storage_full", ingredient)
