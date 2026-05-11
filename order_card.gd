extends ColorRect

var order_difficulty: int = 1
# Called when the node enters the scene tree for the first time.
var order_number := 0
signal order_failed(order_number)
func _ready() -> void:
	generate_order()
	$Timer.wait_time = randf_range(10.0, 15.0)
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	order_timer()
	pass

func generate_order():
	var ingredients = ["tea", "pearls", "milk"]
	var order = {"tea": 1, "pearls": 0, "milk": 0}
	var order_text = ""
	for i in range(order_difficulty):
		order[ingredients[randi() % ingredients.size()]] += 1
	for key in order:
		if order[key] > 0:
			order_text += ("%d %s\n" % [order[key], key])
	$"Label".text = order_text

func order_timer():
	$ProgressBar.value = $"Timer".time_left / $"Timer".wait_time * 100
	var ratio = $"Timer".time_left / $"Timer".wait_time
	var color_ratio = 0.5 * ratio + 0.5
	self.modulate = Color(1, color_ratio, color_ratio)
	$"Timer".time_left

func _on_timer_timeout() -> void:
	print("Order ", order_number, " timed out!")
	emit order_failed(order_number)
	queue_free()

func shift_order_to_position():
	position = Vector2(0,0) + Vector2((order_number-1) * 110, 0)
	print("Shifting order ", order_number, " to position: ", position)
