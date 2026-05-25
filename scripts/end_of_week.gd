extends Control

@onready var grid = $"ColorRect/Summary/VBoxContainer/GridContainer"
@onready var Summary_Manager = get_node("/root/main/SummaryManager")


'''
On load: fetch the weekly summary and
fill the grid with one row per ingredient
'''
func _ready() -> void:
	var summary: Dictionary = Summary_Manager.calculate_weekly_summary()
	populate_summary_grid(summary)


'''
Clears the grid and adds two labels per ingredient:
left column = ingredient name, right column = avg sell price
'''
func populate_summary_grid(summary: Dictionary) -> void:
	for ingredient in summary.keys():
		var name_label = Label.new()
		name_label.text = ingredient
		grid.add_child(name_label)

		var price_label = Label.new()
		price_label.text = "%.2f" % summary[ingredient]
		grid.add_child(price_label)
