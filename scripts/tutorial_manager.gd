extends Node2D

var location_of_text = {}

var steps: Array[Array] = []

@onready var text_label = $Node2D/Panel/Label
@onready var continue_button = $Node2D/Panel/Button
var chars_per_second: float = 80.0

var _current_step: int = 0
var _full_text: String = ""
var _visible_chars: int = 0
var _typing: bool = false
var _time_accum: float = 0.0


func _ready() -> void:
	location_of_text = {
		"center": Vector2(400, 300),
		"top":    Vector2(400, 250),
		"bottom": Vector2(400, 350),
		"left":   Vector2(350, 300),
		"right":  Vector2(450, 300),
	}

	steps = [
		[location_of_text["center"], "So, you think you got what it takes to run a Boba Shop? Your good friend Benny thinks so!"],
		[location_of_text["center"], "It ain't all fun and games, kid. You gotta know the ins and outs of the boba biz to make it work."],
		[location_of_text["center"], "A good business makes a profit. That means selling boba for more than it cost to make."],
		[location_of_text["bottom"], "Buy ingredients by clicking on the bubbles that float up"],
		[location_of_text["left"],  "Get a good deal! Buy ingredients when they're cheap. Check the price on the bubble and the market panel on the left"],
		[location_of_text["right"],   "Your bought goods go to storage. You can only store so much!"],
		[location_of_text["bottom"],    "Down at the bottom is where you make the money. Boba orders come in with different ingredients"],
		[location_of_text["bottom"],    "Click the card to fulfill the order. If you've got enough ingredients, then the order will get fulfilled."],
		[location_of_text["bottom"], "Boba price is determined by the number and cost of ingredients"],
		[location_of_text["top"],    "Up here is the clock and calendar. Events affect the ingredient prices, so keep an eye on it!"],
		[location_of_text["center"], "Each week, you gotta pay $500 in rent to keep your shop open.
		If you can't pay it, you gotta close shop (and lose the game!)"],
		[location_of_text["center"], "I know its a lot, but you got this. When in doubt..."],
		[location_of_text["center"], "Buy ingredients when they are cheap,
		Fill orders when ingredients are expensive,"],
		[location_of_text["center"], "AKA... buy low and sell high!\nBe patient, pay attention, and get rich!"],
		[location_of_text["center"], "Good luck! I'll check back in at the end of the week"],
	]

	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_show_step(0)


func _process(delta: float) -> void:
	if not _typing:
		return
	_time_accum += delta
	var chars_to_add := int(_time_accum * chars_per_second)
	if chars_to_add > 0:
		_time_accum = 0.0
		_visible_chars = mini(_visible_chars + chars_to_add, _full_text.length())
		text_label.text = _full_text.left(_visible_chars)
		if _visible_chars >= _full_text.length():
			_finish_typing()


func _show_step(index: int) -> void:
	_full_text = steps[index][1]
	_visible_chars = 0
	_time_accum = 0.0
	_typing = true
	text_label.text = ""
	continue_button.text = "Skip"
	$Node2D.position = steps[index][0]


func _finish_typing() -> void:
	_typing = false
	text_label.text = _full_text
	continue_button.text = "Start!" if _current_step == steps.size() - 1 else "Continue"


func _end_tutorial() -> void:
	get_tree().paused = false
	queue_free()


func _on_button_pressed() -> void:
	if _typing:
		_finish_typing()
		return
	_current_step += 1
	if _current_step >= steps.size():
		_end_tutorial()
	else:
		_show_step(_current_step)


func _on_skip_button_pressed() -> void:
	_end_tutorial()
	pass # Replace with function body.
