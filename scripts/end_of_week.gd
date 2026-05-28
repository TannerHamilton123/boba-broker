extends Control

@onready var grid = %GridContainer
@onready var Summary_Manager = get_node("/root/main/SummaryManager")
@onready var main = get_node("/root/main")
var upgrades_scene: PackedScene = preload("res://scenes/upgrades.tscn")
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


func _on_button_pressed() -> void:
	var upgrade = upgrades_scene.instantiate()
	main.get_tree().root.add_child(upgrade)
	queue_free()
	pass # Replace with function body.
