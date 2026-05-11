extends Node
const max_orders = 5
var order_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("order_failed", self, "_on_order_failed")
	$Timer.wait_time = randf_range(5.0, 10.0)
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	order_count = $"OrderContainer".get_child_count()
	pass

func add_order():
	
	if order_count < max_orders:
		print("Adding new order. Current order count: ", order_count)
		var new_order = preload("res://order_card.tscn").instantiate()

		$"OrderContainer".add_child(new_order)
		order_count += 1
		new_order.order_number = order_count
		new_order.shift_order_to_position()
		_reorder_orders()


func _reorder_orders():
	var current_number = 1
	for order in $"OrderContainer".get_children():
		order.order_number = current_number
		order.shift_order_to_position()
		current_number += 1
	print("Reordered orders. Current order count: ", order_count)

func _on_timer_timeout() -> void:
	$Timer.wait_time = randf_range(5.0, 10.0)
	$Timer.start()
	add_order()