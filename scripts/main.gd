extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 2.5
var PearlPrice: float = 2.5
var MilkPrice: float = 2.5
var player_balance: float = 50.0
var displayed_balance: float = player_balance - 10.0
var rent: float = 25.0
var game_music = true
var menu_music = false
@onready var after_5_weeks_scene = preload("res://scenes/after_5_weeks.tscn")
var game_over = false
@onready var upgrade_manager = get_node("UpgradeManager")
var has_been_done = false
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
var unlockable_ingredients = ["taro","strawberry","lemon"]


@export var eow_scene: PackedScene
@onready var game_music_player = $sound/game_music
@onready var menu_music_player = $sound/menu_music

'''
This dictionary contains ingredients and data
Ingredients will be added to it after each level
'''
var game_ingredients = {
	"tea": 
		{"quantity": tea_quantity, 
		"Price": TeaPrice, 
		"PriceChange": "stable",
		"Storage_Limit": ingredient_storage,
		"Spawn_Probability": 0.3},

	"milk": 
		{"quantity": milk_quantity, 
		"Price": MilkPrice, 
		"PriceChange": "stable",
		"Storage_Limit": ingredient_storage,
		"Spawn_Probability": 0.3},

	"pearls": 
		{"quantity": pearls_quantity, 
		"Price": PearlPrice, 
		"PriceChange": "stable",
		"Storage_Limit": ingredient_storage,
		"Spawn_Probability": 0.1}
	
	
}




func _ready() -> void:
	if not $DomainValidator.is_valid():
		get_tree().quit()
		return

	await get_tree().create_timer(0.01).timeout
	$sound/menu_music.volume_db = -20
	$sound/game_music.volume_db = -80
	menu_music = true

	var save_data: Dictionary = SaveManager.load_game()
	if save_data.is_empty():
		$Tutorial.visible = true
	else:
		apply_save_data(save_data)
		$TimeManager.start_next_week()
	# create_good_containers()
	# create_storage()

	pass


'''
Snapshot of everything needed to resume a playthrough:
economy stats, unlocked ingredients/upgrades, and week progress.
In-week gameplay state (live orders, bubbles, ingredient quantities)
is intentionally left out - it's cheap to regenerate and resets each week anyway.
'''
func get_save_data() -> Dictionary:
	return {
		"player_balance": player_balance,
		"ingredient_storage": ingredient_storage,
		"popularity": popularity,
		"supply_level": supply_level,
		"wait_time_increase": wait_time_increase,
		"ingredient_level": ingredient_level,
		"weeks_completed": $TimeManager.weeks_completed,
		"upgrade_levels": $UpgradeManager.upgrade_levels,
		"ingredient_quantities": _get_ingredient_quantities(),
	}

'''
Snapshot of how much of each ingredient the player currently has in stock,
so a returning player doesn't resume with empty storage.
'''
func _get_ingredient_quantities() -> Dictionary:
	var quantities: Dictionary = {}
	for ingredient in game_ingredients.keys():
		quantities[ingredient] = game_ingredients[ingredient]["quantity"]
	return quantities

func apply_save_data(data: Dictionary) -> void:
	player_balance = float(data.get("player_balance", player_balance))
	displayed_balance = player_balance
	popularity = int(data.get("popularity", popularity))
	supply_level = int(data.get("supply_level", supply_level))
	wait_time_increase = float(data.get("wait_time_increase", wait_time_increase))

	var saved_upgrade_levels: Dictionary = data.get("upgrade_levels", {})
	for upgrade_type in saved_upgrade_levels.keys():
		if $UpgradeManager.upgrade_levels.has(upgrade_type):
			$UpgradeManager.upgrade_levels[upgrade_type] = int(saved_upgrade_levels[upgrade_type])

	ingredient_storage = int(data.get("ingredient_storage", ingredient_storage))
	var saved_ingredient_level: int = int(data.get("ingredient_level", ingredient_level))
	for level in range(ingredient_level + 1, saved_ingredient_level + 1):
		$UpgradeManager._unlock_ingredient(level)
	ingredient_level = saved_ingredient_level

	var saved_quantities: Dictionary = data.get("ingredient_quantities", {})
	for ingredient in saved_quantities.keys():
		if game_ingredients.has(ingredient):
			game_ingredients[ingredient]["quantity"] = int(saved_quantities[ingredient])

	for ingredient in game_ingredients.keys():
		game_ingredients[ingredient]["Storage_Limit"] = ingredient_storage
	$GameUI/StorageBars.create_storage_lines(ingredient_storage, Color("#c87ab072"), 1.0)

	$TimeManager.weeks_completed = int(data.get("weeks_completed", $TimeManager.weeks_completed))



func _process(delta: float) -> void:
	Global.week_5_profit = player_balance
	# if $Tutorial.visible == true:
	# 	menu_music = true
	# 	game_music = false
	# else:		
	# 	menu_music = false
	# 	game_music = true
	
	if game_music:
		menu_music = false
		if game_music_player.volume_db < -10:
			game_music_player.volume_db += delta * 5.0
			menu_music_player.volume_db -= delta * 5.0
	if menu_music:
		game_music = false
		if menu_music_player.volume_db < -10:
			menu_music_player.volume_db += delta * 5.0
			game_music_player.volume_db -= delta * 5.0
	if game_over:
		SaveManager.clear_save()
		game_music_player.volume_db -= delta * 5.0
		menu_music_player.volume_db -= delta * 5.0
		game_over_sequence()



	# update_good_containers()
	$TimeManager.handle_time(delta)
	displayed_balance = move_toward(displayed_balance, player_balance, delta * 10.0)
	$GameUI/Bank.z_index = 25
	$GameUI/Bank/BankAccount.text = "$%.2f" % displayed_balance
	$GameUI/Bank/BankAccount.self_modulate = bank_color()[0]
	$GameUI/Bank/BankAccount.scale = Vector2(bank_color()[1], bank_color()[1])

func start_next_week() -> void:
	$TimeManager.start_next_week()
	SaveManager.save_game(get_save_data())

func bank_color():
	var difference = player_balance - displayed_balance
	if difference < 0:
		#money is being lost, show red
		return [Color.html("#FFB8C8"),1.1] # Red for losing money
	elif difference > 0:
		return [Color.html("C8F0E0"),1.1] # Green for gaining money
	else:
		return [Color(1, 1, 1),1.00] # White for no change

func _on_not_enough_money(type: String) -> void:
	$sound/fail.play()
	$UIManager.show_notification("Not enough money for %s!" % type)

func _on_no_storage(ingredient: String) -> void:
	$sound/fail.play()
	$UIManager.show_notification("Not enough storage for %s!" % ingredient)

func end_game():
	print("Game Over! Total profit: $%.2f" % player_balance)
	SaveManager.clear_save()
	get_tree().change_scene_to_file("res://scenes/after_5_weeks.tscn")

func game_over_sequence():
	if has_been_done:
		return
	$GameOver.visible = true
	$GameOver/AnimationPlayer.play("game_over")
	has_been_done = true

func _on_restart_pressed() -> void:
	CMGApi.send_game_event("replay", 1)
	SaveManager.clear_save()
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
