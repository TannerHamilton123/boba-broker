extends Area2D

@export var rise_speed: float = 80.0
@export var drift_speed: float = 1.5
@export var drift_amplitude: float = 30.0

signal bubble_clicked(ingredient: String, price: float)
var _time: float = 0.0
var _start_x: float = 0.0
var ingredient: String
var price: float = 1.0
func _ready() -> void:
	_start_x = position.x
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta
	position.y -= rise_speed * delta
	position.x = _start_x + sin(_time * drift_speed) * drift_amplitude


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("bubble_clicked", ingredient, price)
		
		queue_free()
	pass # Replace with function body.


func _on_visibility_screen_exited() -> void:
	queue_free()

func deal_type(ingredient_type: String, bubble_price: float) -> void:
	ingredient = ingredient_type
	price = bubble_price
	$CollisionShape2D.scale = Vector2( 1 + price / 20, 1 + price / 20) # Scale bubble based on price
	match ingredient_type:
		"tea":
			rise_speed = 80.0
			drift_speed = 1.5
			drift_amplitude = 30.0
			$Label.text = "Tea"
			$CollisionShape2D/Circle.modulate = Color(0.8, 0.6, 0.4)
			$Price.text = "$%.2f" % price
			
		"pearls":
			rise_speed = 60.0
			drift_speed = 1.0
			drift_amplitude = 20.0
			$Label.text = "Pearls"
			$CollisionShape2D/Circle.modulate = Color.LIGHT_PINK
			$Price.text = "$%.2f" % price

		"milk":
			rise_speed = 100.0
			drift_speed = 2.0
			drift_amplitude = 40.0
			$Label.text = "Milk"
			$CollisionShape2D/Circle.modulate = Color(1.0, 1.0, 1.0)
			$Price.text = "$%.2f" % price
