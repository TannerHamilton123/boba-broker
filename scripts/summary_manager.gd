extends Node

# fulfilled_orders : every completed order this week
#   entry format   : { "order": {ingredient: qty, ...}, "price": float }
#
# ingredient_revenue[ingredient] : { "qty_sold": int, "total_revenue": float }
# ingredient_cost[ingredient]    : { "qty_bought": int, "total_cost": float }

var fulfilled_orders: Array = []
var ingredient_revenue: Dictionary = {}
var ingredient_cost: Dictionary = {}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

# Splits an order's sale price evenly across every ingredient unit it contains
# and accumulates the share into ingredient_revenue.
func _accumulate_ingredient_revenue(order: Dictionary, price: float) -> void:
	var total_units: int = 0
	for ingredient in order.keys():
		total_units += order[ingredient]
	if total_units == 0:
		return

	var price_per_unit: float = price / total_units
	for ingredient in order.keys():
		if not ingredient_revenue.has(ingredient):
			ingredient_revenue[ingredient] = {"qty_sold": 0, "total_revenue": 0.0}
		ingredient_revenue[ingredient]["qty_sold"]       += order[ingredient]
		ingredient_revenue[ingredient]["total_revenue"]  += order[ingredient] * price_per_unit

# Records one unit purchase of an ingredient at the given cost.
func _accumulate_ingredient_cost(ingredient: String, cost: float) -> void:
	if not ingredient_cost.has(ingredient):
		ingredient_cost[ingredient] = {"qty_bought": 0, "total_cost": 0.0}
	ingredient_cost[ingredient]["qty_bought"] += 1
	ingredient_cost[ingredient]["total_cost"] += cost

# Returns a per-ingredient breakdown for the EOW summary screen.
# Each value is a Dictionary:
#   qty_sold       - units used in fulfilled orders
#   total_revenue  - total dollars earned from orders containing this ingredient
#   avg_revenue    - average revenue per unit sold (total_revenue / qty_sold)
#   qty_bought     - units purchased from deal bubbles
#   total_cost     - total dollars spent buying this ingredient
#   avg_cost       - average price paid per unit (total_cost / qty_bought)
#   margin         - avg_revenue - avg_cost
func calculate_weekly_summary() -> Dictionary:
	var summary: Dictionary = {}

	var all_ingredients: Array = []
	for i in ingredient_revenue.keys():
		all_ingredients.append(i)
	for i in ingredient_cost.keys():
		if not all_ingredients.has(i):
			all_ingredients.append(i)

	for ingredient in all_ingredients:
		var qty_sold: int       = 0
		var total_revenue: float = 0.0
		var qty_bought: int     = 0
		var total_cost: float   = 0.0

		if ingredient_revenue.has(ingredient):
			qty_sold      = ingredient_revenue[ingredient]["qty_sold"]
			total_revenue = ingredient_revenue[ingredient]["total_revenue"]

		if ingredient_cost.has(ingredient):
			qty_bought = ingredient_cost[ingredient]["qty_bought"]
			total_cost = ingredient_cost[ingredient]["total_cost"]

		var avg_revenue: float = total_revenue / qty_sold  if qty_sold  > 0 else 0.0
		var avg_cost: float    = total_cost    / qty_bought if qty_bought > 0 else 0.0

		summary[ingredient] = {
			"qty_sold":      qty_sold,
			"total_revenue": total_revenue,
			"avg_revenue":   avg_revenue,
			"qty_bought":    qty_bought,
			"total_cost":    total_cost,
			"avg_cost":      avg_cost,
			"margin":        avg_revenue - avg_cost,
		}

	return summary

# Resets all accumulators for the next week.
func reset_week() -> void:
	fulfilled_orders.clear()
	ingredient_revenue.clear()
	ingredient_cost.clear()
