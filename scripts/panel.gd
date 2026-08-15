extends Panel

var top = 0.0
var bottom = 0.0
var width = 150.0
@onready var main = get_node("/root/main")

var _max_storage: int = 0
var _line_color: Color = Color("#c87ab072")
var _line_width: float = 1.0

func _ready() -> void:
	visible_bars()
	_max_storage = main.ingredient_storage
	queue_redraw()

func process(_delta: float) -> void:
	visible_bars()

func _draw() -> void:
	var font = ThemeDB.fallback_font
	var font_size = 16
	for i in range(1, _max_storage):
		var y = size.y * (1.0 - i / float(_max_storage))
		draw_line(Vector2(0, y), Vector2(size.x, y), _line_color, _line_width)
		draw_string(font, Vector2(8, y - 2), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.html("c87ab0"))
		

func create_storage_lines(max_storage: int, line_color: Color, line_width: float) -> void:
	_max_storage = max_storage
	_line_color = line_color
	_line_width = line_width
	queue_redraw()

func visible_bars():
	for bar in get_children():
		bar.visible = false
	for ingredient in main.game_ingredients.keys():
		
		var bar = get_node_or_null(ingredient)
		if bar != null:
			# print("Making bar visible for ", ingredient)
			bar.visible = true
