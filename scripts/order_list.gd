extends Node
const max_orders = 5
const IN_DEMAND_THRESHOLD = 2.51
var order_count = 0
var popularity = 0.0
'''
The lowest price of a drink is $5.00
The price increases with the difficulty, and some variety
'''
var initial_price = 5.0

'''
Happiness ranges from 0 to 100, with 100 being the happiest. 
It decreases by 10 for each failed order and increases by 10 for each completed order.
Happiness affects the timer
Happiness increases and decreases are handled by main.gd
'''
var happiness_score := 20.0

"""
Difficulty ranges from 1 to 5
Difficulty affects order complexity (number of ingredients)
Difficulty increases based on happiness score
Difficulty 1: 2 ingredients
Difficulty 2: 2 ingredients
Difficulty 3: 3 ingredients
Difficulty 4: 4 ingredients
Difficulty 5: 4 ingredients

"""
var order_difficulty: int = 1

func _ready() -> void:
	$Timer.wait_time = randf_range(5.0, 10.0)
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	popularity = get_node("/root/main").popularity

	if happiness_score < 0:
		happiness_score = 0
	elif happiness_score > 100:
		happiness_score = 100

	order_count = $"OrderContainer".get_child_count()
	for order in $"OrderContainer".get_children():
		shift_orders(order, _delta)
	pass

func add_order():
	if order_count < max_orders:
		var new_order = preload("res://scenes/order_card.tscn").instantiate()
		$"OrderContainer".add_child(new_order)
		order_count += 1
		new_order.order_number = order_count
		new_order.order = generate_order()
		var market_price = generate_market_price(new_order.order)
		new_order.price = market_price[0]
		new_order.in_demand = market_price[1]
		new_order.label_order()
		new_order.position = Vector2(800, 0)
		_reorder_orders()
		

'''
Everytime an order is fulfilled or failed, we need to reorder the remaining orders to fill in the gap and update their order numbers
The orders will slide to the left to fill in the gap, and their order numbers will be updated accordingly
This is handled by the _reorder_orders() function, which is called after an order is fulfilled or failed
'''
func _reorder_orders():
	var current_number = 1
	for order in $"OrderContainer".get_children():
		if not "order_number" in order:
			continue
		order.order_number = current_number
		current_number += 1

func shift_orders(order, delta):
	if not "order_number" in order:
		return
	var position = Vector2(0,0) + Vector2((order.order_number-1) * 110, 0)
	order.position -= (order.position - position) * delta/2


func generate_order():
	var number_of_ingredients = difficulty_check()
	if number_of_ingredients >= 6:
		number_of_ingredients = 6
	var game_ingredients = get_node("/root/main").game_ingredients
	var order = {"tea": 1, "milk": 1}
	var ingredient_list = game_ingredients.keys()
	for i in range(number_of_ingredients):
		var ingredient = ingredient_list[randi() % ingredient_list.size()]

		while ingredient in order and order[ingredient] >= 2:
			ingredient = ingredient_list[randi() % ingredient_list.size()]
		if ingredient in order:
			order[ingredient] += 1
		else:
			order[ingredient] = 1
	

	return order


func generate_market_price(order):
	var in_demand = false
	var order_price = 0.00
	for ingredient in order.keys():
		var ingredient_data = get_node("/root/main").game_ingredients[ingredient]
		var effective_price = ingredient_data["Price"] + ingredient_data["Premium"]
		if effective_price > IN_DEMAND_THRESHOLD:
			in_demand = true
		order_price += effective_price * order[ingredient]

	return [order_price, in_demand]



'''	
Adjust timer based on happiness
At 0 happiness, timer is 5-10 seconds
At 100 happiness, timer is 1-2 seconds
'''


func _on_timer_timeout() -> void:

	var min_range = 3.0 - 2 * happiness_score/100.0 - popularity * 0.5
	var max_range = 5.0 - 4 * happiness_score/100.0 - popularity * 0.5
	$Timer.wait_time = randf_range(min_range, max_range)
	$Timer.start()
	add_order()


func difficulty_check():



	
	order_difficulty = clamp(happiness_score / 20, 1, 5)

	#orders start with 2 ingredients,
	#Then the number of ingredients ranges from 1 to 3 based on difficulty
	#At 50 happiness, a total of 4 ingredients will be in an order
	#At 100 happiness, a total of 5 ingredients will be in an order
	var number_of_ingredients = min(order_difficulty, 4)
	return number_of_ingredients
