extends Node

'''
fulfilled_orders: list of every completed order this week
	each entry: { "order": {ingredient: qty, ...}, "price": float }
ingredient_totals: running totals per ingredient for the week
	each entry: { ingredient: { "quantity": int, "revenue": float } }
'''
@onready var main = get_node("/root/main")
var fulfilled_orders: Array = []
var ingredient_revenue: Dictionary = {}
var ingredient_cost: Dictionary = {}
var week_revenue: float = 0.0
var week_cost: float = 0.0
var week_profit: float = 0.0
var sold_orders: int = 0
var week_start_bank_balance: float
var ingredient_summary: Dictionary = {}
var total_ingredients_sold: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	week_start_bank_balance = main.player_balance
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	pass
'''
For one order, splits the price evenly per ingredient unit
and adds each ingredient's share to ingredient_totals
'''
func _accumulate_ingredient_revenue(order: Dictionary, price: float) -> void:
	sold_orders += 1
	week_revenue += price
	
	var total_units: int = 0
	for ingredient in order.keys():
		total_ingredients_sold += 1
		total_units += order[ingredient]

	if total_units == 0:
		return

	var price_per_unit: float = price / total_units

	for ingredient in order.keys():
		if not ingredient_revenue.has(ingredient):
			ingredient_revenue[ingredient] = { "quantity": 0, "revenue": 0.0 }
		ingredient_revenue[ingredient]["quantity"] += order[ingredient]
		ingredient_revenue[ingredient]["revenue"] += order[ingredient] * price_per_unit

'''
For finding the average cost of ingredients bought from deal bubbles
'''
func _accumulate_ingredient_cost(ingredient,cost):
	if not ingredient_cost.has(ingredient):
		ingredient_cost[ingredient] = { "quantity": 1, "cost": cost }
	ingredient_cost[ingredient]["quantity"] += 1
	ingredient_cost[ingredient]["cost"] += cost
	ingredient_cost[ingredient]["quantity"] += 1



'''
Returns a dict of each ingredient's average sell price per unit
based on all orders fulfilled this week
'''
func calculate_weekly_summary():

	week_profit = main.player_balance - week_start_bank_balance
	week_cost = week_revenue - week_profit - main.rent
	

	var all_ingredients: Array = ingredient_revenue.keys()
	for ingredient in ingredient_cost.keys():
		if not all_ingredients.has(ingredient):
			all_ingredients.append(ingredient)

	for ingredient in all_ingredients:
		var avg_revenue: float = 0.0
		var avg_cost: float = 0.0

		if ingredient_revenue.has(ingredient) and ingredient_revenue[ingredient]["quantity"] > 0:
			avg_revenue = ingredient_revenue[ingredient]["revenue"] / ingredient_revenue[ingredient]["quantity"]

		if ingredient_cost.has(ingredient) and ingredient_cost[ingredient]["quantity"] > 0:
			avg_cost = ingredient_cost[ingredient]["cost"] / ingredient_cost[ingredient]["quantity"]

		ingredient_summary[ingredient] = avg_revenue - avg_cost




'''
Resets stored orders and totals for the next week
'''
func reset_week() -> void:
	total_ingredients_sold = 0
	fulfilled_orders.clear()
	ingredient_revenue.clear()
	ingredient_cost.clear()
	ingredient_summary.clear()
	sold_orders = 0
	week_revenue = 0.0
	week_cost = 0.0
	week_profit = 0.0
	week_start_bank_balance = main.player_balance
