extends Control

@onready var Summary_Manager = get_node("/root/main/SummaryManager")
@onready var main = get_node("/root/main")
@onready var upgrades_scene: PackedScene = preload("res://scenes/upgrades.tscn")
@onready var category = get_node("ColorRect/Summary/category")
@onready var quantity = get_node("ColorRect/Summary/quantity")
'''
On load: fetch the weekly summary and
fill the grid with one row per ingredient
'''
func _ready() -> void:
	main.menu_music = true
	$AnimationPlayer.play("start")
	#Pay Rent
	main.player_balance -= main.rent
	check_game_over()

	Summary_Manager.calculate_weekly_summary()
	populate_summary_grid()


'''
Clears the grid and adds two labels per ingredient:
left column = ingredient name, right column = avg sell price
'''
func populate_summary_grid() -> void:
	var total_ingredients_sold = Summary_Manager.total_ingredients_sold
	var boba_sold = Summary_Manager.sold_orders
	var week_revenue = Summary_Manager.week_revenue
	var week_cost = Summary_Manager.week_cost
	var week_profit = Summary_Manager.week_profit

	var gains_from_each_ingredient = 0.0
	if total_ingredients_sold > 0:
		gains_from_each_ingredient = week_revenue / total_ingredients_sold
	quantity.get_node("OrdersFulfilled").text = str(boba_sold)
	quantity.get_node("Revenue").text = "$%.2f" % week_revenue
	quantity.get_node("IngredientCosts").text = "$%.2f" % week_cost
	quantity.get_node("Profit").text = "$%.2f" % week_profit
	quantity.get_node("GainsFromEachIngredient").text = "$%.2f" % gains_from_each_ingredient



func _on_button_pressed() -> void:
	var upgrade = upgrades_scene.instantiate()
	main.get_tree().root.add_child(upgrade)
	queue_free()
	pass # Replace with function body.

func check_game_over() -> void:
	if main.player_balance <= 0:
		main.game_over = true