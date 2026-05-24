extends Node

@onready var main = get_parent()

var time: String = ""
var day: String = ""
var day_length: float = 10
var time_elapsed: float = 0.0
var shop_open_hour: int = 10
var shop_close_hour: int = 20
var shop_hours: int = shop_close_hour - shop_open_hour
var days_of_week: Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
var current_day_index: int = 0
var week_is_active: bool = true
var weeks_completed: int = 0

@export var eow_scene: PackedScene
func _process(delta: float) -> void:
	_update_day_tracker()


func handle_time(delta: float) -> void:
	if not week_is_active:
		return

	time_elapsed += delta

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
	main.get_node("GameUI/TimeTracker/clock").text = ("Day: %s  Time: %s" % [day, time])


func _update_day_tracker():
	var percent_of_day = time_elapsed/day_length * 100.0
	var percent_of_week = current_day_index + percent_of_day/100

	$"../GameUI/TimeTracker/DayTracker".value = percent_of_day
	$"../GameUI/TimeTracker/WeekTracker".value = percent_of_week

func end_week() -> void:
	week_is_active = false
	weeks_completed += 1
	_stop_timers()
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
