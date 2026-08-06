
extends Node

var upgrade_types = ["Storage", "Ingredient", "WaitTime", "Popularity","Supply"]
var upgrade_levels = {
	"Storage": 0,
	"Ingredient": 0,
	"WaitTime": 0,
	"Popularity": 0,
	"Supply": 0
}
var upgrade_max_levels = {
	"Storage": 5,
	"Ingredient": 3,
	"WaitTime": 5,
	"Popularity": 5,
	"Supply": 5
}
@onready var main = get_node("/root/main")
@onready var ui_manager = get_node("/root/main/UIManager")
@onready var storage_panel = get_node("/root/main/GameUI/StorageBars")
signal not_enough_money(upgrade_type: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("not_enough_money", main._on_not_enough_money)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_UpgradeButton_pressed(upgrade_type: String,price: float) -> void:
	if main.player_balance < price:
		emit_signal("not_enough_money", upgrade_type)
		return

	if upgrade_levels[upgrade_type] >= upgrade_max_levels[upgrade_type]:
		print("Upgrade ", upgrade_type, " is already at max level!")
		return

	main.player_balance -= price
	if upgrade_type == "Storage":
		upgrade_storage()
	elif upgrade_type == "Ingredient":
		upgrade_ingredient()
	elif upgrade_type == "WaitTime":
		upgrade_wait_time()
	elif upgrade_type == "Popularity":
		upgrade_popularity()
	elif upgrade_type == "Supply":
		upgrade_supply()
	else:
		print("Unknown upgrade type: ", upgrade_type)
		return



func upgrade_storage() -> void:
	main.ingredient_storage += 5
	upgrade_levels["Storage"] += 1
	_refresh_button("Storage")
	for ingredient in main.game_ingredients.keys():
		main.game_ingredients[ingredient]["Storage_Limit"] = main.ingredient_storage
	storage_panel.create_storage_lines(main.ingredient_storage, Color("#c87ab072"), 1.0)

func upgrade_ingredient() -> void:
	main.ingredient_level += 1
	upgrade_levels["Ingredient"] += 1
	_refresh_button("Ingredient")
	_unlock_ingredient(main.ingredient_level)
	print("Ingredient quality upgraded to level ", upgrade_levels["Ingredient"])

func upgrade_wait_time() -> void:
	main.wait_time_increase += 2
	upgrade_levels["WaitTime"] += 1
	_refresh_button("WaitTime")
	print("Wait time reduction upgraded to level ", upgrade_levels["WaitTime"])

func upgrade_popularity() -> void:
	main.popularity += 1
	upgrade_levels["Popularity"] += 1
	_refresh_button("Popularity")
	print("Popularity upgraded to level ", upgrade_levels["Popularity"])

func upgrade_supply() -> void:
	main.supply_level += 1
	upgrade_levels["Supply"] += 1
	_refresh_button("Supply")
	print("Supply upgraded to level ", upgrade_levels["Supply"])

'''
Finds the matching button in the EOW scene and
updates its level then refreshes its label text
'''
func _refresh_button(_upgrade_type: String) -> void:
	var upgrades_page = get_tree().root.get_node_or_null("UpgradesPage")
	if upgrades_page == null:
		return
	var upgrade_buttons = upgrades_page.get_node("ColorRect/HBoxContainer")

	# Refresh all buttons to see if they are affordable or maxed out
	for button in upgrade_buttons.get_children():
		if button.upgrade_type == _upgrade_type or button.disabled:
			continue
		
		button.refresh_label()


func _unlock_ingredient(level: int) -> void:
	var new_ingredient = main.unlockable_ingredients[level-1]

	main.game_ingredients[new_ingredient] = {"quantity": 0,
	"Price": 2.5,
	"Premium": UpgradeData.premiums["Ingredient"][level - 1],
	"PriceChange": "stable",
	"Storage_Limit": main.ingredient_storage,
	"Spawn_Probability": 0.1}

	print("Unlocked new ingredient: ", new_ingredient)
	print("Level ", level, " ingredient unlocked: ", new_ingredient)
	print("main.game_ingredients: ", main.game_ingredients)
	var PriceBar_icons = get_node("/root/main/GameUI/PriceBar/icons")
	PriceBar_icons.get_node(new_ingredient).visible = true
	var StorageBars = get_node("/root/main/GameUI/StorageBars")
	StorageBars.get_node(new_ingredient).visible = true
