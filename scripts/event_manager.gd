extends Node

'''
Ingredient prices only ever sit at one of these three tiers.
Events push a price to high_price or low_price; it reverts to
medium_price (the default) once the event ends.
'''
@export var high_price: float = 5.0
@export var medium_price: float = 2.5
@export var low_price: float = 1.0

@onready var main = get_node("/root/main")
@onready var available = main.game_ingredients.keys()
@onready var time_manager = main.get_node("TimeManager")
var events = {
	"tea": [
		{
			"name": "Someone spilled the tea!",
			"description": "Less tea to go around.
			Prices rise sharply.",
			"symbol": "up",
		},
		{
			"name": "Tea Festival",
			"description": "A local tea festival has driven up prices.",
			"symbol": "up",
		},
		{
			"name": "Super tea leaf discovered!",
			"description": "An exceptional harvest floods the market.
			Tea prices drop.",
			"symbol": "down",
		},
	],
	"milk": [
		{
			"name": "Cows on Strike!",
			"description": "The cows don't want to produce milk!
			Milk costs much more.",
			"symbol": "up",
		},
		{
			"name": "Good Farm Connections",
			"description": "A nearby farm is offering a bulk discount.
			Milk prices fall.",
			"symbol": "down",
		},
		{
			"name": "An Udder Disaster!",
			"description": "No cows were harmed, but our profit is!
			Milk costs more.",
			"symbol": "up",
		},
	],
	"pearls": [
		{
			"name": "Tapioca Tornado Disaster!",
			"description": "Pearls cost much more!",
			"symbol": "up",
		},
		{
			"name": "Tapioca Takeover",
			"description": "New Tapioca tycoon is selling at a discount.
			Costs go down.",
			"symbol": "down",
		},
		{
			"name": "Tapioca Oversupply",
			"description": "Too much tapioca is a good thing!
			Prices go down.",
			"symbol": "down",
		},
	],
	"taro": [
		{
			"name": "Rooting for the Root",
			"description": "Great taro harvest this season.",
			"symbol": "down",
		},
		{
			"name": "Big Trouble in little Taro Shipping",
			"description": "Shipping delays have cut taro imports.
			Prices spike hard.",
			"symbol": "up",
		},
		{
			"name": "Taro Craze",
			"description": "Taro flavored everything is everywhere.
			Prices are going up.",
			"symbol": "up",
		},
	],
	"strawberry": [
		{
			"name": "Berry Blast!",
			"description": "A great strawberry season
			Strawberry prices are down.",
			"symbol": "down",
		},
		{
			"name": "Bears eat berries!",
			"description": "They gotta eat!
			But prices are up!",
			"symbol": "up",
		},
		{
			"name": "Summer Special",
			"description": "Summer heat has spiked demand.
			Suppliers are charging more.",
			"symbol": "up",
		},
	],
	"lemon": [
		{
			"name": "Suppply Chain Soured!",
			"description": "A frost damaged citrus crops.
			Lemon prices have jumped.",
			"symbol": "up",
		},
		{
			"name": "Life gives you lemons",
			"description": "Lets sell them for a discount!
			Lemons are cheap.",
			"symbol": "down",
		},
		{
			"name": "Lemonade Trend",
			"description": "Lemon boba is the drink of the season.
			Prices have climbed.",
			"symbol": "up",
		},
	],
}

var scheduled_events: Array = []

func trigger_event(ingredient: String, event: Dictionary, event_duration:= 10.0) -> void:


	var baseline_spawn = main.game_ingredients[ingredient]["Spawn_Probability"]
	#This baseline may be an issue, since i have varying spawn rates for the ingredients, but if there are 2 back to back events,
	#Then they will overwrite the baseline.

	var event_description = main.get_node("GameUI/Event/EventDescription")
	var event_name_title = main.get_node("GameUI/Event/EventTitle")
	var event_panel = main.get_node("GameUI/Event")
	if not main.game_ingredients.has(ingredient):
		return
	if event["symbol"] == "up":
		main.game_ingredients[ingredient]["Price"] = high_price
	elif event["symbol"] == "down":
		main.game_ingredients[ingredient]["Price"] = low_price
	for i in range(2): #Apply the spawn multiplier 2 times for a more dramatic effect
		main.get_node("BubbleSpawner").bag.push_front(ingredient) #Regenerate the bag to apply spawn probability changes immediately
	print(main.get_node("BubbleSpawner").bag)
	
	print("Event triggered: [", ingredient, "] ", event["name"], " — ", event["description"])

	event_name_title.text = "%s: %s" % [ingredient.capitalize(), event["name"]]
	event_panel.visible = true
	event_description.text = event["description"]
	await get_tree().create_timer(5.0).timeout
	event_panel.visible = false

	#When the event times out, revert all changes to the ingredient's price and spawn probability
	await get_tree().create_timer(maxf(event_duration - 5.0, 0.0)).timeout
	main.game_ingredients[ingredient]["Spawn_Probability"] = baseline_spawn
	main.game_ingredients[ingredient]["Price"] = medium_price


func _pick_random_event() -> Dictionary:
	if available.size() == 0:
		available = main.game_ingredients.keys()
	var ingredient = available[randi() % available.size()]
	available.erase(ingredient)
	var ingredient_events = events[ingredient]
	var event = ingredient_events[randi() % ingredient_events.size()]
	return {"ingredient": ingredient, "event": event}

func schedule_week_events(event_count: int = 7) -> void:
	#var base_ingredients = ["milk","tea"]
	scheduled_events.clear()
	#var time_manager = main.get_node("TimeManager")
	var day_pool = range(time_manager.days_of_week.size())
	day_pool.shuffle()





	for i in range(1,event_count):
		var picked = _pick_random_event()
		var day_index = day_pool[i]
		var trigger_time = time_manager.day_length /2.0
		scheduled_events.append({
			"ingredient": picked["ingredient"],
			"event": picked["event"],
			"day_index": day_index,
			"trigger_time": trigger_time,
			"triggered": false,
		})
		print("Scheduled: [Day %d at %.1fs] %s — %s" % [day_index, trigger_time, picked["ingredient"], picked["event"]["name"]])

func _check_scheduled_events() -> void:
	
	if not time_manager.week_is_active:
		return
	for scheduled in scheduled_events:
		if scheduled["triggered"]:
			continue
		if time_manager.current_day_index == scheduled["day_index"] and time_manager.time_elapsed >= scheduled["trigger_time"]:
			trigger_event(scheduled["ingredient"], scheduled["event"])
			scheduled["triggered"] = true
			print("Event triggered: [Day %d at %.1fs] %s — %s" % [scheduled["day_index"], scheduled["trigger_time"], scheduled["ingredient"], scheduled["event"]["name"]])

func _ready() -> void:
	begin_week_scheduling()
	pass

func _process(_delta: float) -> void:
	_check_scheduled_events()

func add_event_to_calendar():
	#var week_bar = main.get_node("GameUI/TimeTracker/WeekTracker")
	var bar_width = 800.0
	var total_days = 7.0
	var day_len = time_manager.day_length

	for scheduled in scheduled_events:
		var ingredient_scene = load("res://scenes/" + scheduled["ingredient"] + ".tscn")
		var event_node = ingredient_scene.instantiate()
		if scheduled["event"]["symbol"] == "up":
			event_node.get_node("Arrows/up_arrow").visible = true
		elif scheduled["event"]["symbol"] == "down":
			event_node.get_node("Arrows/down_arrow").visible = true
		else:
			event_node.modulate = Color(1, 1, 1)

		var day_fraction = scheduled["trigger_time"] / day_len
		var x_pos = (scheduled["day_index"] + day_fraction) / total_days * bar_width
		event_node.position = Vector2(x_pos, 35)
		main.get_node("GameUI/TimeTracker/Events").add_child(event_node)

func begin_week_scheduling():
	for child in main.get_node("GameUI/TimeTracker/Events").get_children():
		child.queue_free()
	scheduled_events.clear()
	available = main.game_ingredients.keys()
	schedule_week_events()
	add_event_to_calendar()
