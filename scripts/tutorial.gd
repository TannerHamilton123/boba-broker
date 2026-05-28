class_name TutorialManager
extends CanvasLayer

# Emitted when the last step closes — connect in main to do any post-tutorial setup.
signal tutorial_complete

const TYPEWRITER_SPEED := 0.035   # seconds per character

# ── STEP DEFINITIONS ──────────────────────────────────────────────────────────
# text           : speech bubble content
# pause          : freeze gameplay (timers, time) during this step
# resume_for     : seconds to let the game run freely after Continue is pressed
#                  before the next step interrupts; 0 = go straight to next step
# highlight_path : NodePath from main root — reserved for a future highlight-ring
#                  feature; leave "" if unused
const STEPS: Array = [
	{
		"text": "Welcome to Boba Broker! I'm here to help you get your bubble tea shop off the ground. Let me show you around!",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": ""
	},
	{
		"text": "The bars at the top track the time of day and the day of the week. Your shop runs from 10 AM to 8 PM — once the clock hits closing time the day ends!",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": "GameUI/TimeTracker"
	},
	{
		"text": "The panel on the left is the price bar. Each ingredient icon floats up or down as market prices change. Buy ingredients when their icon is low!",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": "GameUI/PriceBar"
	},
	{
		"text": "Your ingredient storage is on the right. Each item has a maximum capacity — if you're full you can't buy more until you use some up.",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": "GameUI/Storage"
	},
	{
		"text": "Orders appear at the bottom of the screen. Each card asks for a specific drink. Fulfill them to earn money! Let's watch a few come in...",
		"pause": true,
		"resume_for": 4.0,
		"highlight_path": "OrderList/OrderContainer"
	},
	{
		"text": "See how orders roll in? Fill them fast — customers don't wait forever. Keep an eye on your bank balance as you earn and spend.",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": ""
	},
	{
		"text": "Sometimes market events will shake up prices. Watch the clock area for ingredient icons with arrows — they warn you a price spike or drop is coming. Let's see the market in motion...",
		"pause": true,
		"resume_for": 5.0,
		"highlight_path": "GameUI/TimeTracker"
	},
	{
		"text": "At the end of the week an upgrade shop opens. Spend your earnings on extra storage, new ingredients, and more customers. Good luck — the market waits for no one!",
		"pause": true,
		"resume_for": 0.0,
		"highlight_path": ""
	},
]

# ── UI NODES ──────────────────────────────────────────────────────────────────
var _overlay: ColorRect
var _bubble: PanelContainer
var _character_label: Label      # placeholder until character art exists; swap for TextureRect
var _text_label: RichTextLabel
var _continue_btn: Button

# ── STATE ─────────────────────────────────────────────────────────────────────
var _step: int = 0
var _typing: bool = false
var _full_text: String = ""
var _char_index: int = 0
var _type_timer: float = 0.0

var _resuming: bool = false      # true while game runs freely between steps
var _resume_timer: float = 0.0

# ── LIFECYCLE ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build_ui()
	_show_step(0)

func _process(delta: float) -> void:
	if _resuming:
		_resume_timer -= delta
		if _resume_timer <= 0.0:
			_resuming = false
			_show_step(_step)
		return

	if _typing:
		_type_timer -= delta
		if _type_timer <= 0.0:
			_type_timer = TYPEWRITER_SPEED
			_char_index += 1
			_text_label.text = _full_text.left(_char_index)
			if _char_index >= _full_text.length():
				_finish_typing()

# ── STEP CONTROL ──────────────────────────────────────────────────────────────
func _show_step(index: int) -> void:
	if index >= STEPS.size():
		_end_tutorial()
		return

	var step: Dictionary = STEPS[index]
	_overlay.visible = true
	_continue_btn.visible = false

	if step["pause"]:
		get_tree().paused = true

	_full_text = step["text"]
	_char_index = 0
	_type_timer = TYPEWRITER_SPEED
	_typing = true
	_text_label.text = ""

func _finish_typing() -> void:
	_typing = false
	_text_label.text = _full_text
	_continue_btn.visible = true

func _on_continue_pressed() -> void:
	# First press while still typing: skip to full text instead of advancing.
	if _typing:
		_finish_typing()
		return

	var step: Dictionary = STEPS[_step]
	_step += 1

	var resume_for: float = step.get("resume_for", 0.0)
	if resume_for > 0.0:
		# Hide overlay and let the game run for resume_for seconds.
		_overlay.visible = false
		get_tree().paused = false
		_resume_timer = resume_for
		_resuming = true
	else:
		_show_step(_step)

func _end_tutorial() -> void:
	get_tree().paused = false
	_overlay.visible = false
	tutorial_complete.emit()
	queue_free()

# ── PUBLIC API ────────────────────────────────────────────────────────────────

# Jump directly to a named step by searching the STEPS array.
# Useful if you want to re-trigger a specific section from elsewhere.
func go_to_step(step_id_text_prefix: String) -> void:
	for i in range(STEPS.size()):
		if STEPS[i]["text"].begins_with(step_id_text_prefix):
			_step = i
			_resuming = false
			_show_step(_step)
			return

# Pause gameplay and show a one-off bubble not in the step list.
# Returns immediately; the bubble dismisses with Continue as normal,
# then resumes gameplay and emits tutorial_complete.
func show_interruption(message: String, pause: bool = true) -> void:
	var one_off := {
		"text": message,
		"pause": pause,
		"resume_for": 0.0,
		"highlight_path": ""
	}
	# Temporarily inject into the step array at the current position.
	var mutable := STEPS.duplicate(true)
	mutable.insert(_step, one_off)
	# Override with the injected version just for this call.
	# _step already points to the one-off; after Continue it advances past it.
	_overlay.visible = true
	_continue_btn.visible = false
	if pause:
		get_tree().paused = true
	_full_text = message
	_char_index = 0
	_type_timer = TYPEWRITER_SPEED
	_typing = true
	_text_label.text = ""

# ── UI BUILDER ────────────────────────────────────────────────────────────────
# Creates the overlay entirely in code — no companion .tscn needed.
# Once character art and final styling are ready, replace this with a proper
# scene file and update the @onready references above.
func _build_ui() -> void:
	# Semi-transparent full-screen backdrop
	_overlay = ColorRect.new()
	_overlay.color = Color(0.18, 0.12, 0.22, 0.72)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	# Character placeholder — replace with TextureRect once art exists
	_character_label = Label.new()
	_character_label.text = "( ◕‿◕ )"
	_character_label.add_theme_font_size_override("font_size", 36)
	_character_label.anchor_left   = 0.1
	_character_label.anchor_right  = 0.35
	_character_label.anchor_top    = 0.55
	_character_label.anchor_bottom = 0.75
	_character_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_overlay.add_child(_character_label)

	# Speech bubble
	_bubble = PanelContainer.new()
	_bubble.anchor_left   = 0.08
	_bubble.anchor_right  = 0.92
	_bubble.anchor_top    = 0.72
	_bubble.anchor_bottom = 0.96
	_overlay.add_child(_bubble)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_bubble.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = false
	_text_label.fit_content = true
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(0, 60)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_text_label)

	_continue_btn = Button.new()
	_continue_btn.text = "Continue"
	_continue_btn.visible = false
	_continue_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_continue_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(_continue_btn)
