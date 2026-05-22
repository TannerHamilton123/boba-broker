extends ColorRect

var order_difficulty: int = 1
var order
var price
# Called when the node enters the scene tree for the first time.
var order_number := 0
signal order_failed(order_number)
signal order_fulfilled(order_number, order,price)
func _ready() -> void:
	connect("order_fulfilled", get_node("/root/main")._on_order_fulfilled)
	connect("order_failed", get_node("/root/main")._on_order_failed)
	
	$Timer.wait_time = randf_range(10.0, 15.0)
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	order_timer()
	pass

func label_order():
	var order_text = ""
	for ingredient in order.keys():
		order_text += str(order[ingredient]) + " " + ingredient.capitalize() + "\n"
	order_text += "$%.2f" % price
	$"Label".text = order_text

func order_timer():
	$ProgressBar.value = $"Timer".time_left / $"Timer".wait_time * 100
	var ratio = $"Timer".time_left / $"Timer".wait_time
	var color_ratio = 0.5 * ratio + 0.5
	self.modulate = Color(1, color_ratio, color_ratio)

func _on_timer_timeout() -> void:
	print("Order ", order_number, " timed out!")
	emit_signal("order_failed")
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
	emit_signal("order_fulfilled", order_number,order,price)
	queue_free()

	