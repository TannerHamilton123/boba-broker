class_name PriceEventManager
extends Node

# Emitted when an event fires — connect to show the popup text.
signal event_fired(event: Dictionary)
# Emitted after build_week_events() — connect to draw clock indicators.
signal week_events_built(events: Array)

const DAILY  = "daily"   # fires every day at the given hour
const WEEKLY = "weekly"  # fires once per week on a fixed day + hour
const ONCE   = "once"    # drawn randomly; fires at most once ever

# Price bounds (mirrors price_calculator.gd)
const MIN_PRICE := 1.0
const MAX_PRICE := 5.0

# ── EVENT POOL ───────────────────────────────────────────────────────────────
# Fields:
#   id          unique string identifier
#   ingredient  key in main.game_ingredients ("tea","pearls","milk","taro","lemon","strawberry")
#   day         day name, or "any" (resolved to a real day when the week is built)
#   hour        game hour to fire (10–19)
#   multiplier  price *= multiplier  (>1 = up, <1 = down)
#   description short text shown to the player
#   recurrence  DAILY | WEEKLY | ONCE

const EVENT_POOL: Array = [

	# ── DAILY ────────────────────────────────────────────────────────────────
	{
		"id": "morning_tea_rush",
		"ingredient": "tea",
		"day": "any",
		"hour": 11,
		"multiplier": 1.2,
		"description": "Morning rush — tea demand is surging!",
		"recurrence": DAILY
	},
	{
		"id": "afterschool_pearls",
		"ingredient": "pearls",
		"day": "any",
		"hour": 15,
		"multiplier": 1.15,
		"description": "After-school crowd wants bubble tea!",
		"recurrence": DAILY
	},
	{
		"id": "evening_cooldown",
		"ingredient": "milk",
		"day": "any",
		"hour": 18,
		"multiplier": 0.9,
		"description": "Evening slowdown — milk prices ease off.",
		"recurrence": DAILY
	},

	# ── WEEKLY ───────────────────────────────────────────────────────────────
	{
		"id": "monday_supplier_deal",
		"ingredient": "tea",
		"day": "Monday",
		"hour": 10,
		"multiplier": 0.85,
		"description": "Monday supplier deal — tea is cheaper today.",
		"recurrence": WEEKLY
	},
	{
		"id": "wednesday_taro_trend",
		"ingredient": "taro",
		"day": "Wednesday",
		"hour": 12,
		"multiplier": 1.2,
		"description": "Midweek taro craze picks back up!",
		"recurrence": WEEKLY
	},
	{
		"id": "friday_milk_rush",
		"ingredient": "milk",
		"day": "Friday",
		"hour": 17,
		"multiplier": 1.25,
		"description": "TGIF! Milk tea orders are pouring in.",
		"recurrence": WEEKLY
	},
	{
		"id": "saturday_pearl_rush",
		"ingredient": "pearls",
		"day": "Saturday",
		"hour": 11,
		"multiplier": 1.3,
		"description": "Weekend rush — pearls are flying off shelves!",
		"recurrence": WEEKLY
	},
	{
		"id": "sunday_slow",
		"ingredient": "tea",
		"day": "Sunday",
		"hour": 14,
		"multiplier": 0.88,
		"description": "Lazy Sunday — tea demand drops a little.",
		"recurrence": WEEKLY
	},

	# ── ONE-TIME (large market events) ───────────────────────────────────────
	{
		"id": "tapioca_shortage",
		"ingredient": "pearls",
		"day": "any",
		"hour": 13,
		"multiplier": 2.0,
		"description": "Tapioca shortage! Pearl prices have doubled.",
		"recurrence": ONCE
	},
	{
		"id": "tea_harvest_boom",
		"ingredient": "tea",
		"day": "any",
		"hour": 10,
		"multiplier": 0.6,
		"description": "Bumper tea harvest — prices drop sharply!",
		"recurrence": ONCE
	},
	{
		"id": "dairy_strike",
		"ingredient": "milk",
		"day": "any",
		"hour": 14,
		"multiplier": 1.8,
		"description": "Dairy delivery strike — milk prices surge!",
		"recurrence": ONCE
	},
	{
		"id": "taro_goes_viral",
		"ingredient": "taro",
		"day": "any",
		"hour": 12,
		"multiplier": 1.65,
		"description": "Taro milk tea went viral overnight!",
		"recurrence": ONCE
	},
	{
		"id": "health_report_milk",
		"ingredient": "milk",
		"day": "any",
		"hour": 11,
		"multiplier": 0.6,
		"description": "A health report tanks milk demand.",
		"recurrence": ONCE
	},
	{
		"id": "pearl_surplus",
		"ingredient": "pearls",
		"day": "any",
		"hour": 15,
		"multiplier": 0.7,
		"description": "Tapioca surplus — pearl prices tumble!",
		"recurrence": ONCE
	},
	{
		"id": "boba_festival",
		"ingredient": "tea",
		"day": "any",
		"hour": 13,
		"multiplier": 1.5,
		"description": "Local Boba Festival sends tea demand soaring!",
		"recurrence": ONCE
	},
	{
		"id": "influencer_taro",
		"ingredient": "taro",
		"day": "any",
		"hour": 16,
		"multiplier": 1.9,
		"description": "A mega-influencer just posted about taro boba!",
		"recurrence": ONCE
	},
	{
		"id": "lemon_harvest",
		"ingredient": "lemon",
		"day": "any",
		"hour": 10,
		"multiplier": 0.65,
		"description": "Great lemon harvest — prices are low this week!",
		"recurrence": ONCE
	},
	{
		"id": "strawberry_frost",
		"ingredient": "strawberry",
		"day": "any",
		"hour": 12,
		"multiplier": 1.75,
		"description": "Late frost damaged the strawberry crop — prices spike!",
		"recurrence": ONCE
	},
]

# ── STATE ─────────────────────────────────────────────────────────────────────
var week_events: Array = []          # events active for the current week
var fired_this_week: Array = []       # "id_day" keys already fired this week
var spent_once_ids: Array = []        # ONCE event ids that have fired ever

var _last_hour: int = -1
var _last_day: String = ""

@onready var time_manager: Node = get_parent().get_node("TimeManager")
@onready var main: Node = get_parent()

# ── LIFECYCLE ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	build_week_events()

func _process(_delta: float) -> void:
	if not time_manager.week_is_active:
		return
	_check_events()

# ── PUBLIC API ────────────────────────────────────────────────────────────────

# Call this at the start of every new week (including the first).
# Also called automatically from _ready().
func build_week_events() -> void:
	week_events.clear()
	fired_this_week.clear()
	_last_hour = -1
	_last_day = ""

	for event in EVENT_POOL:
		if event["recurrence"] == DAILY:
			week_events.append(event)
		elif event["recurrence"] == WEEKLY:
			week_events.append(event)

	# Pick 1–3 unspent ONCE events and assign them a random day
	var available: Array = []
	for event in EVENT_POOL:
		if event["recurrence"] == ONCE and not spent_once_ids.has(event["id"]):
			available.append(event)
	available.shuffle()
	var pick_count: int = min(randi_range(1, 3), available.size())
	for i in range(pick_count):
		var e: Dictionary = available[i].duplicate()
		e["day"] = time_manager.days_of_week[randi() % time_manager.days_of_week.size()]
		week_events.append(e)

	emit_signal("week_events_built", week_events)

# Returns events that will fire within lookahead_hours from now on the current day.
# Use this to draw upcoming indicators on the clock.
func get_upcoming_events(lookahead_hours: int = 2) -> Array:
	var current_hour := _get_current_hour()
	var current_day  := time_manager.day
	var upcoming: Array = []
	for event in week_events:
		if fired_this_week.has(_fire_key(event, current_day)):
			continue
		var day_matches := event["day"] == "any" or event["day"] == current_day
		if day_matches and event["hour"] > current_hour and event["hour"] <= current_hour + lookahead_hours:
			upcoming.append(event)
	return upcoming

# ── INTERNALS ─────────────────────────────────────────────────────────────────

func _check_events() -> void:
	var current_hour := _get_current_hour()
	var current_day  := time_manager.day

	# Only process once per game-hour per day
	if current_hour == _last_hour and current_day == _last_day:
		return
	_last_hour = current_hour
	_last_day  = current_day

	for event in week_events:
		var key := _fire_key(event, current_day)
		if fired_this_week.has(key):
			continue
		var day_matches := event["day"] == "any" or event["day"] == current_day
		if day_matches and event["hour"] == current_hour:
			_fire_event(event, current_day)

func _fire_event(event: Dictionary, current_day: String) -> void:
	var ingredient: String = event["ingredient"]
	if not main.game_ingredients.has(ingredient):
		return

	var old_price: float = main.game_ingredients[ingredient]["Price"]
	var new_price: float = clampf(old_price * event["multiplier"], MIN_PRICE, MAX_PRICE)
	main.game_ingredients[ingredient]["Price"]       = new_price
	main.game_ingredients[ingredient]["PriceChange"] = "up" if event["multiplier"] >= 1.0 else "down"

	fired_this_week.append(_fire_key(event, current_day))
	if event["recurrence"] == ONCE:
		spent_once_ids.append(event["id"])

	emit_signal("event_fired", event)

func _get_current_hour() -> int:
	var progress: float = time_manager.time_elapsed / time_manager.day_length
	return int(time_manager.shop_open_hour + progress * time_manager.shop_hours)

func _fire_key(event: Dictionary, day: String) -> String:
	return event["id"] + "|" + day
