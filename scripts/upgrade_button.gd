extends Button

var upgrade_type: String = ""
var current_level: int = 0
var upgrade_description
var upgrade_name
var price_label
var upgrade_manager
var level_label 
var price: float = 0.0
@onready var main = get_node("/root/main")
@export var upgrade_description_text: String = ""
'''
Sets button text from UpgradeData based on
upgrade_type and current_level
'''
func _ready() -> void:
	
	upgrade_description = $UpgradeDescription
	upgrade_name = $UpgradeName
	price_label = $Price
	upgrade_manager = get_tree().root.get_node("main/UpgradeManager")
	upgrade_type = self.name
	current_level = upgrade_manager.upgrade_levels[upgrade_type]
	level_label = $Level
	refresh_label()


'''
Looks up the label for the current level;
shows "Maxed Out" if all levels are purchased
'''
func refresh_label() -> void:
	if upgrade_type == "":
		return
	var levels: Array = UpgradeData.labels[upgrade_type]
	if current_level >= levels.size():
		upgrade_name.text = upgrade_type + ": Maxed Out"
		upgrade_description.text = "You've purchased all available upgrades for " + upgrade_type + "!"
		price_label.text = ""
		self.disabled = true
	else:
		level_label.text = "Level " + str(current_level)
		upgrade_name.text = levels[current_level]
		upgrade_description.text = upgrade_description_text
		price = UpgradeData.prices[upgrade_type][current_level]
		price_label.text = "$%d" % int(price)

		self.disabled = false


func _on_pressed() -> void:
	if price > main.player_balance:
		print("Not enough money to purchase ", upgrade_type, " upgrade!")
		return
	print("Buying " + upgrade_type + "for " + str(price))

	#add dollar sign instance
	main.get_node("sound/click").play()
	main.get_node("sound/casino").play()
	change_text_color()

	upgrade_manager._on_UpgradeButton_pressed(upgrade_type,price)
	self.disabled = true # Prevent multiple clicks until label is refreshed



	pass

func change_text_color() -> void:
	$UpgradeDescription.modulate = Color.html("c87ab0")
	$UpgradeName.modulate = Color.html("c87ab0")
	$Price.modulate = Color.html("c87ab0")
