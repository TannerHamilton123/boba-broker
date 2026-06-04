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

@onready var main = get_node("/root/main")
@onready var TimeTracker = get_node("/root/main/GameUI/TimeTracker")
@onready var PriceBar = get_node("/root/main/GameUI/PriceBar")
@onready var StorageBars = get_node("/root/main/GameUI/StorageBars")
@onready var OrderList = get_node("/root/main/OrderList/OrderContainer")
@onready var Bank = get_node("/root/main/GameUI/Bank")
@onready var rent_amount = main.rent
func _ready() -> void:
	print("starting tutorial fade in")
	$Node2D/AnimationPlayer.play("start")
	await $Node2D/AnimationPlayer.animation_finished
	print("tutorial fade in done")
	main.get_node("sound/menu_music").volume_db = -5
	rent_amount = "$%.2f" % main.rent
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
		[location_of_text["center"], "A good business makes a profit. That means selling boba for more than it costs to make."],
		[location_of_text["bottom"], "Buy ingredients by clicking on the bubbles that float up."],
		[location_of_text["left"],  "Get a good deal! Buy ingredients when they're cheap. Check the price on the bubble and the market panel on the left.", PriceBar],
		[location_of_text["right"],   "Your bought goods go to storage. You can only store so much!", StorageBars],
		[location_of_text["bottom"],    "Down at the bottom is where you make the money. Boba orders come in with different ingredients.", OrderList],
		[location_of_text["bottom"],    "Click the card to fulfill the order. If you've got enough ingredients, then the order will get fulfilled.", OrderList],
		[location_of_text["bottom"], "Selling price is determined by the number and cost of ingredients.
		Orders get red if customers wait too long, then they'll leave!", OrderList],
		[location_of_text["top"],    "Up here is the clock and calendar. Events affect the ingredient prices, so keep an eye on it!.", TimeTracker],
		[location_of_text["center"], "Each week, you gotta pay " + rent_amount + " in rent to keep your shop open.\nIf you can't pay it, you gotta close shop (and lose the game!)",Bank],
		[location_of_text["center"], "I know its a lot, but you got this. When in doubt..."],
		[location_of_text["center"], "Buy ingredients when they are cheap,
		Fill orders when ingredients are expensive."],
		[location_of_text["center"], "AKA... buy low and sell high!\nBe patient, pay attention, and get rich!"],
		[location_of_text["center"], "Good luck! Here's some seed money to get started: $50", Bank],
		[location_of_text["center"], "I'll check back in at the end of the week"],
	]

	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_show_step(0)


func _process(delta: float) -> void:
	if main.get_node("sound/menu_music").volume_db < 0 and main.menu_music:
		main.get_node("sound/menu_music").volume_db += delta * 0.5

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

	if index == 6 or index == 7:
		$OrderCard.visible = true
	else:		
		$OrderCard.visible = false

	if index == 3:
		print("Showing bubble for step ", index)
		$bubble.visible = true
	else:		
		$bubble.visible = false

	if steps[index -1].size() >=3:
		steps[index -1][2].z_index = 0
		print("Resetting z-index of ", steps[index -1][2])

	_full_text = steps[index][1]
	_visible_chars = 0
	_time_accum = 0.0
	_typing = true
	text_label.text = ""
	continue_button.text = "Skip"
	$Node2D.position = steps[index][0]
	$Node2D/AnimationPlayer.play("pop_up")

	if steps[index].size() >= 3:
		var ui_element = steps[index][2]
		ui_element.z_index = 100


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
