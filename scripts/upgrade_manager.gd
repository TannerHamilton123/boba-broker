
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_UpgradeButton_pressed(upgrade_type: String) -> void:
	print("Upgrade button pressed: ", upgrade_type)
	if upgrade_levels[upgrade_type] >= upgrade_max_levels[upgrade_type]:
		print("Upgrade ", upgrade_type, " is already at max level!")
		return
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



func upgrade_storage() -> void:

	main.ingredient_storage += 5
	upgrade_levels["Storage"] += 1
	_refresh_button("Storage")

func upgrade_ingredient() -> void:
	main.ingredient_level += 1
	upgrade_levels["Ingredient"] += 1
	_refresh_button("Ingredient")
	_unlock_ingredient(main.ingredient_level)
	print("Ingredient quality upgraded to level ", upgrade_levels["Ingredient"])

func upgrade_wait_time() -> void:
	main.wait_time_increase += 0.1
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
func _refresh_button(upgrade_type: String) -> void:
	pass


func _unlock_ingredient(level: int) -> void:
	var new_ingredient = main.all_ingredients[level]
	main.game_ingredients[new_ingredient] = {"quantity": 0, "Price": 1.0, "PriceChange": "stable","Storage_Limit": main.ingredient_storage}