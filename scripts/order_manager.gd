extends Node

@onready var main = get_parent()
@onready var ui_manager = get_parent().get_node("UIManager")

'''
fulfilled_orders: list of every completed order this week
	each entry: { "order": {ingredient: qty, ...}, "price": float }
ingredient_totals: running totals per ingredient for the week
	each entry: { ingredient: { "quantity": int, "revenue": float } }
'''
var fulfilled_orders: Array = []
var ingredient_totals: Dictionary = {}


'''
Receives a fulfilled order; stores it and
accumulates per-ingredient revenue split evenly by unit count
'''
func _on_order_fulfilled(order: Dictionary, price: float) -> void:
	fulfilled_orders.append({ "order": order, "price": price })
	_accumulate_ingredient_revenue(order, price)

	print("Order fulfilled! Details: ", order, " Price: ", price)
	main.player_balance += price
	for ingredient in order.keys():
		main.game_ingredients[ingredient]["quantity"] -= order[ingredient]
	ui_manager.update_good_containers()
	ui_manager.update_storage()
	await get_tree().create_timer(0.1).timeout
	main.get_node("OrderList").call_deferred("_reorder_orders")


'''
For one order, splits the price evenly per ingredient unit
and adds each ingredient's share to ingredient_totals
'''
func _accumulate_ingredient_revenue(order: Dictionary, price: float) -> void:
	var total_units: int = 0
	for ingredient in order.keys():
		total_units += order[ingredient]

	if total_units == 0:
		return

	var price_per_unit: float = price / total_units

	for ingredient in order.keys():
		if not ingredient_totals.has(ingredient):
			ingredient_totals[ingredient] = { "quantity": 0, "revenue": 0.0 }
		ingredient_totals[ingredient]["quantity"] += order[ingredient]
		ingredient_totals[ingredient]["revenue"] += order[ingredient] * price_per_unit


'''
Returns a dict of each ingredient's average sell price per unit
based on all orders fulfilled this week
'''
func calculate_weekly_summary() -> Dictionary:
	var averages: Dictionary = {}
	for ingredient in ingredient_totals.keys():
		var qty: int = ingredient_totals[ingredient]["quantity"]
		var revenue: float = ingredient_totals[ingredient]["revenue"]
		averages[ingredient] = revenue / qty if qty > 0 else 0.0
	return averages


'''
Resets stored orders and totals for the next week
'''
func reset_week() -> void:
	fulfilled_orders.clear()
	ingredient_totals.clear()


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
	main.player_balance -= price
	ui_manager.update_good_containers()
	ui_manager.update_storage()
