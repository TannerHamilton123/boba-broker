extends Control

@onready var grid = $"ColorRect/Summary/VBoxContainer/GridContainer"
@onready var Summary_Manager = get_node("/root/main/SummaryManager")

const COLOR_POSITIVE := Color(0.129, 0.502, 0.314)  # #208050
const COLOR_NEGATIVE := Color(0.753, 0.251, 0.376)  # #C04060
const COLOR_NEUTRAL  := Color(0.290, 0.231, 0.322)  # #4A3B52 (Brown Sugar)
const COLOR_HEADER   := Color(0.784, 0.478, 0.690)  # #C87AB0 (Taro Accent)

func _ready() -> void:
	var summary: Dictionary = Summary_Manager.calculate_weekly_summary()
	populate_summary_grid(summary)

# Replaces all grid children with a 5-column ingredient breakdown:
# Ingredient | Bought | Avg Cost | Avg Rev/Unit | Margin
func populate_summary_grid(summary: Dictionary) -> void:
	for child in grid.get_children():
		child.queue_free()

	grid.columns = 5

	# Header row
	for header in ["Ingredient", "Bought", "Avg Cost", "Avg Rev/Unit", "Margin"]:
		var lbl := Label.new()
		lbl.text = header
		lbl.add_theme_color_override("font_color", COLOR_HEADER)
		grid.add_child(lbl)

	# One row per ingredient
	for ingredient in summary.keys():
		var data: Dictionary = summary[ingredient]

		var avg_cost:    float = data["avg_cost"]
		var avg_revenue: float = data["avg_revenue"]
		var margin:      float = data["margin"]

		_add_label(grid, ingredient.capitalize(), COLOR_NEUTRAL)
		_add_label(grid, str(data["qty_bought"]),          COLOR_NEUTRAL)
		_add_label(grid, "$%.2f" % avg_cost,               COLOR_NEUTRAL)
		_add_label(grid, "$%.2f" % avg_revenue,            COLOR_NEUTRAL)

		var margin_text := ("+" if margin >= 0 else "") + "$%.2f" % margin
		var margin_color := COLOR_POSITIVE if margin > 0.0 else (COLOR_NEGATIVE if margin < 0.0 else COLOR_NEUTRAL)
		_add_label(grid, margin_text, margin_color)

func _add_label(parent: Node, text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	parent.add_child(lbl)
