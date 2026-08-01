extends Node

@onready var main = get_parent()
@onready var Summary_Manager = get_node("/root/main/SummaryManager")
var time: String = ""
var day: String = ""
@export var day_length: float = 30.0
var time_elapsed: float = 0.0
var shop_open_hour: int = 10
var shop_close_hour: int = 20
var shop_hours: int = shop_close_hour - shop_open_hour
var days_of_week: Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
var current_day_index: int = 0
var week_is_active: bool = true
var weeks_completed: int = 0
var tick_tock_played: bool = false

@export var eow_scene: PackedScene
@export var total_weeks: int = 10


func _ready() -> void:
	if not SaveManager.has_save():
		start_next_week()
func _process(delta: float) -> void:
	$"../GameUI/StartWeek".modulate.a -= delta * 0.2
	_update_day_tracker()
	handle_time(delta)


func handle_time(delta: float) -> void:
	if not week_is_active:
		return

	time_elapsed += delta

	var time_remaining = (days_of_week.size() - current_day_index) * day_length - time_elapsed
	if time_remaining <= 9.0 and not tick_tock_played:
		tick_tock_played = true
		main.get_node("sound/tick_tock").play()

	if time_elapsed >= day_length:
		time_elapsed -= day_length
		var next_index: int = current_day_index + 1
		if next_index >= days_of_week.size():
			end_week()
			return
		current_day_index = next_index

	var progress: float = time_elapsed / day_length
	var game_hour_float: float = shop_open_hour + progress * shop_hours
	var current_hour: int = int(game_hour_float)
	var current_minute: int = int((game_hour_float - current_hour) * 60)

	var suffix: String = "AM" if current_hour < 12 else "PM"
	var display_hour: int = current_hour if current_hour <= 12 else current_hour - 12
	time = "%d:%02d %s" % [display_hour, current_minute, suffix]
	day = days_of_week[current_day_index]
	main.get_node("GameUI/TimeTracker/Panel2/clock").text = ("Week %d\n%s" %[weeks_completed + 1, day])


func _update_day_tracker():
	var percent_of_day = time_elapsed/day_length * 100.0
	var percent_of_week = current_day_index + percent_of_day/100

	$"../GameUI/TimeTracker/DayTracker".value = percent_of_day
	$"../GameUI/TimeTracker/WeekTracker".value = percent_of_week

func end_week() -> void:
	week_is_active = false
	weeks_completed += 1
	_stop_timers()
	main.player_balance -= main.rent
	SaveManager.save_game(main.get_save_data())
	if weeks_completed >= total_weeks:
		main.game_over = true
		main.end_game()
	else:
		_show_eow()

func _stop_timers() -> void:
	main.get_node("PriceCalculator/Timer").stop()
	main.get_node("BubbleSpawner/Timer").stop()
	main.get_node("OrderList/Timer").stop()

func _show_eow() -> void:
	if eow_scene == null:
		push_warning("eow_scene is not assigned in the Inspector.")
		return
	var eow = eow_scene.instantiate()
	main.get_tree().root.add_child(eow)

func start_next_week() -> void:
	$"../GameUI/StartWeek".modulate.a = 1.0
	$"../GameUI/StartWeek".text = "Starting Week %d" % (weeks_completed + 1)
	if weeks_completed >= 1:
		$"../GameUI/StartWeek".text = "Continue to Week %d" % (weeks_completed + 1)
	if weeks_completed >= total_weeks - 1:
		$"../GameUI/StartWeek".text = "Final Week!"
	
	$"../GameUI/StartWeek".visible = true
	week_is_active = true
	current_day_index = 0
	time_elapsed = 0.0
	tick_tock_played = false
	main.get_node("PriceCalculator/Timer").start()
	main.get_node("BubbleSpawner/Timer").start()
	main.get_node("OrderList/Timer").start()
	main.get_node("EventManager").begin_week_scheduling()
	main.get_node("UIManager").start_new_week()
	Summary_Manager.reset_week()
