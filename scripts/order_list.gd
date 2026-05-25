extends Node
const max_orders = 5
var order_count = 0

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
var happiness_score := 50

"""
Difficulty ranges from 1 to 5
Difficulty affects price and order complexity (number of ingredients)
Difficulty increases based on happiness score
Difficulty 1: 2 ingredient, price multiplier 1.0
Difficulty 2: 2 ingredients, price multiplier 1.5
Difficulty 3: 3 ingredients, price multiplier 2.0
Difficulty 4: 4 ingredients, price multiplier 2.5
Difficulty 5: 5 ingredients, price multiplier 3.0

"""
var order_difficulty: int = 1

func _ready() -> void:
	$Timer.wait_time = randf_range(5.0, 10.0)
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
		var order_data = generate_order()
		new_order.order = order_data[0]
		new_order.price = order_data[1]
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
	print("Reordering orders..." + str($"OrderContainer".get_child_count()) + " orders remaining.")
	for order in $"OrderContainer".get_children():
		order.order_number = current_number
		
		current_number += 1

func shift_orders(order,delta):
	var position = Vector2(0,0) + Vector2((order.order_number-1) * 110, 0)
	order.position -= (order.position - position) * delta


func generate_order():
	var number_of_ingredients = difficulty_check()[0]
	var price_multiplier = difficulty_check()[1]
	var price = initial_price * price_multiplier
	var game_ingredients = get_node("/root/main").game_ingredients
	var order = {"tea": 1, "milk": 1}
	var ingredient_list = game_ingredients.keys()
	for i in range(number_of_ingredients):
		var ingredient = ingredient_list[randi() % ingredient_list.size()]

		if ingredient in order:
			while order[ingredient] > 2: # limit to 2 of the same ingredient per order
				ingredient = ingredient_list[randi() % ingredient_list.size()]
		if ingredient in order:
			order[ingredient] += 1
		else:
			order[ingredient] = 1
	return [order, price]



'''	
adjust timer based on happiness score, 
with a range of 5 to 10 seconds at 0 happiness 
and 1 to 2 seconds at 100 happiness
Starting at 3.5 to 12 seconds at 50 happiness
'''
func _on_timer_timeout() -> void:
	
	var happiness_modifier = (100.0 - happiness_score) / 20.0 + 1.0
	var min_range = 1.0 * happiness_modifier
	var max_range = 2.0 * happiness_modifier
	$Timer.wait_time = randf_range(min_range, max_range)
	$Timer.start()
	add_order()


func difficulty_check():
	order_difficulty = floor(min(5, 1.0 + happiness_score / 20.0))
	#determine number of ingredients based on difficulty
	#Determine price based on difficulty
	var number_of_ingredients = min(order_difficulty, 5)-2
	var price_multiplier = 1.0 + (order_difficulty - 1) * 0.5
	return [number_of_ingredients, price_multiplier]
