extends Control

@onready var grid = $"ColorRect/Summary/VBoxContainer/GridContainer"
@onready var order_manager = get_node("/root/main/OrderManager")


'''
On load: fetch the weekly summary and
fill the grid with one row per ingredient
'''
func _ready() -> void:
	var summary: Dictionary = order_manager.calculate_weekly_summary()
	populate_summary_grid(summary)


'''
Clears the grid and adds two labels per ingredient:
left column = ingredient name, right column = avg sell price
'''
func populate_summary_grid(summary: Dictionary) -> void:
	for child in grid.get_children():
		child.queue_free()

	for ingredient in summary.keys():
		var name_label := Label.new()
		name_label.text = "Avg %s price:" % ingredient.capitalize()

		var value_label := Label.new()
		value_label.text = "$%.2f" % summary[ingredient]

		grid.add_child(name_label)
		grid.add_child(value_label)
