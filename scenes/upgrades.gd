extends Panel

var upgrade_types = ["Storage", "Ingredient", "WaitTime", "Popularity","Supply"]
var upgrade_levels = {
	"Storage": 0,
	"Ingredient": 0,
	"WaitTime": 0,
	"Popularity": 0,
	"Supply": 0
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

func set_price(upgrade_type: String) -> int:
	var base_price = 100
	var level = upgrade_levels[upgrade_type]
	return base_price * (level + 1)

func upgrade_storage() -> void:
	var price = set_price("Storage")
	main.ingredient_storage += 5
	upgrade_levels["Storage"] += 1
	print("Storage upgraded to level ", upgrade_levels["Storage"], " for $", price)

func upgrade_ingredient() -> void:
	main.ingredient_level += 1
	upgrade_levels["Ingredient"] += 1
	print("Ingredient quality upgraded to level ", upgrade_levels["Ingredient"])

func upgrade_wait_time() -> void:
	main.wait_time_increase += 0.1
	upgrade_levels["WaitTime"] += 1
	print("Wait time reduction upgraded to level ", upgrade_levels["WaitTime"])

func upgrade_popularity() -> void:
	main.popularity += 1
	upgrade_levels["Popularity"] += 1
	print("Popularity upgraded to level ", upgrade_levels["Popularity"])

func upgrade_supply() -> void:
	main.supply_level += 1
	upgrade_levels["Supply"] += 1
	print("Supply upgraded to level ", upgrade_levels["Supply"])