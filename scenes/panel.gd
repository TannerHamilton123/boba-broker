extends Panel

var top = 0.0
var bottom = 0.0
var width = 150.0
@onready var main = get_node("/root/main")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	create_storage_lines(main.ingredient_storage, Color("#c87ab072"), 1.0)

func create_storage_lines(max_storage: int, line_color: Color, line_width: float) -> void:
	for i in range(1, max_storage):
		var y = size.y * (1.0 - i / float(max_storage))
		draw_line(Vector2(0, y), Vector2(size.x, y), line_color, line_width)
