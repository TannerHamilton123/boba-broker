extends ColorRect

var order_difficulty: int = 1
var order
var price
# Called when the node enters the scene tree for the first time.
var order_number := 0

@onready var main = get_node("/root/main")
@onready var OrderManager = get_node("/root/main/OrderManager")

signal order_failed(order,price)
signal order_fulfilled(order,price)
func _ready() -> void:
	connect("order_fulfilled", OrderManager._on_order_fulfilled)
	connect("order_failed", OrderManager._on_order_failed)

	#wait time is variable, plus the effects of upgrades that represent a customers willingness to wait longer
	var wait_time_increase = main.wait_time_increase

	$Timer.wait_time = randf_range(10.0, 15.0) + wait_time_increase - order_difficulty

	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	order_timer()
	pass

func label_order():
	var col_positions = [16, 54]
	var row_positions = [18, 54]
	var icon_index = 0

	for ingredient in order.keys():
		var quantity = order[ingredient]
		for i in range(quantity):
			var col = icon_index % 2
			var row: int = int(icon_index / 2.0)
			var ingredient_icon = load("res://scenes/"+ingredient+".tscn").instantiate()
			ingredient_icon.position = Vector2(col_positions[col], row_positions[row])
			self.add_child(ingredient_icon)
			icon_index += 1

	$"Label".text = "$%.2f" % price

func order_timer():
	$ProgressBar.value = $"Timer".time_left / $"Timer".wait_time * 100
	var ratio = $"Timer".time_left / $"Timer".wait_time
	var color_ratio = 0.5 * ratio + 0.5
	$ColorRect.modulate = Color(1, color_ratio, color_ratio)

func _on_timer_timeout() -> void:
	print("Order ", order_number, " timed out!")
	emit_signal("order_failed",order,price)
	queue_free()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Clicked on order ", order_number)
		check_order()

func check_order():
	var game_ingredients = get_node("/root/main").game_ingredients
	for ingredient in order.keys():
		if game_ingredients[ingredient]["quantity"] < order[ingredient]:
			print("Order ", order_number, " failed! Not enough ", ingredient)
			return
	
	#All ingredients are present, so now order is fulfilled
	print("Order ", order_number, " fulfilled!")
	emit_signal("order_fulfilled",order,price)
	queue_free()

	