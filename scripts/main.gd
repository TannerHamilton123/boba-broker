extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 1.0
var PearlPrice: float = 1.0
var MilkPrice: float = 1.0
var player_balance: float = 100.0




'''
Upgrade Stats
These stats are modified by the upgrade shop and affect gameplay in various ways
Other scripts will reference these variables to apply the effects of upgrades
'''
var ingredient_storage: int = 5
var popularity : int = 0
var supply_level : int = 0
var wait_time_increase: float = 0.0
var ingredient_level: int = 0
var all_ingredients = ["tea","pearls","milk","taro",]


@export var eow_scene: PackedScene


'''
This dictionary contains ingredients and data
Ingredients will be added to it after each level
'''
var game_ingredients = {
	"tea": {"quantity": tea_quantity, "Price": TeaPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage},
	"pearls": {"quantity": pearls_quantity, "Price": PearlPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage},
	"milk": {"quantity": milk_quantity, "Price": MilkPrice, "PriceChange": "stable","Storage_Limit": ingredient_storage}
}




func _ready() -> void:
	$Tutorial.visible = true
	# create_good_containers()
	# create_storage()
	
	pass



func _process(delta: float) -> void:
	# update_good_containers()
	$TimeManager.handle_time(delta)
	$GameUI/BankAccount.text = "Balance: $%.2f" % player_balance

func start_next_week() -> void:
	$TimeManager.start_next_week()
