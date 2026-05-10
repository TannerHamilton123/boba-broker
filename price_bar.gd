extends VSlider
var ingredient: String
var price : float = 1.0
var _target: float

const MIN_PRICE = 1.0
const MAX_PRICE = 10.0
func _ready() -> void:
	self.min_value = MIN_PRICE
	self.max_value = MAX_PRICE
	price = randf_range(MIN_PRICE, MAX_PRICE)
	self.value = price
	_target = price
	$"price_change".wait_time = randf_range(1.0, 5.0)

func _process(delta: float) -> void:
	price = lerp(price, _target, delta/2.0)
	self.value = price # Smoothly transition to the target price




func _on_price_change_timeout() -> void:
	var new_price = randf_range(MIN_PRICE, MAX_PRICE)
	# print("New price: ", new_price)
	_target = int(new_price)
	$"price_change".wait_time = randf_range(5.0, 10.0)
