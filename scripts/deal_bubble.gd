extends Area2D

@export var rise_speed: float = 80.0
@export var drift_speed: float = 1.5
@export var drift_amplitude: float = 30.0

signal bubble_clicked(ingredient: String, price: float)
var _time: float = 0.0
var _start_x: float = 0.0
var ingredient: String
var price: float = 1.0
var milk_sprite_scene       = preload("res://scenes/milk.tscn")
var tea_sprite_scene        = preload("res://scenes/tea.tscn")
var pearls_sprite_scene     = preload("res://scenes/pearls.tscn")
var lemon_sprite_scene      = preload("res://scenes/lemon.tscn")
var strawberry_sprite_scene = preload("res://scenes/strawberry.tscn")
var taro_sprite_scene       = preload("res://scenes/taro.tscn")

func _ready() -> void:
	_start_x = position.x
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta
	position.y -= rise_speed * delta
	position.x = _start_x + sin(_time * drift_speed) * drift_amplitude


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var main = get_node("/root/main")
	var ingredient_storage = main.ingredient_storage
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if main.game_ingredients[ingredient]["quantity"] < ingredient_storage:
			emit_signal("bubble_clicked", ingredient, price)
			#signal picked up at order manager
			queue_free()
	pass # Replace with function body.


func _on_visibility_screen_exited() -> void:
	queue_free()

func deal_type(ingredient_type: String, bubble_price: float) -> void:
	ingredient = ingredient_type
	price = bubble_price
	$CollisionShape2D.scale = Vector2(1 + price / 20, 1 + price / 20)
	match ingredient_type:
		"tea":
			rise_speed = 80.0
			drift_speed = 1.5
			drift_amplitude = 30.0
			var sprite = tea_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
		"pearls":
			rise_speed = 60.0
			drift_speed = 1.0
			drift_amplitude = 20.0
			var sprite = pearls_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
		"milk":
			rise_speed = 100.0
			drift_speed = 2.0
			drift_amplitude = 40.0
			var sprite = milk_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
		"taro":
			rise_speed = 50.0
			drift_speed = 0.8
			drift_amplitude = 15.0
			var sprite = taro_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
		"lemon":
			rise_speed = 110.0
			drift_speed = 2.5
			drift_amplitude = 45.0
			var sprite = lemon_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
		"strawberry":
			rise_speed = 90.0
			drift_speed = 1.8
			drift_amplitude = 35.0
			var sprite = strawberry_sprite_scene.instantiate()
			sprite.position = Vector2.ZERO
			add_child(sprite)
	$CollisionShape2D/Circle.modulate = _price_color(price)
	$Price.text = "$%.2f" % price
	$Price.add_theme_constant_override("outline_size", 6)
	$Price.add_theme_color_override("font_outline_color", Color.html("4A3B52"))

# $1 → Matcha Mint (#C8F0E0), $2.50 → Cream (#FFF8F0), $5 → Rose (#FFB8C8)
func _price_color(p: float) -> Color:
	var mint  := Color.html("C8F0E0")
	var cream := Color.html("FFF8F0")
	var rose  := Color.html("FFB8C8")
	var t := clampf((p - 1.0) / 4.0, 0.0, 1.0)
	return mint.lerp(cream, t * 2.0) if t <= 0.5 else cream.lerp(rose, (t - 0.5) * 2.0)
