extends Button

var upgrade_type: String = ""
var current_level: int = 0
var upgrade_description
var upgrade_name
var price_label
var upgrade_manager
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
		upgrade_name.text = levels[current_level]
		upgrade_description.text = upgrade_type
		var price = UpgradeData.prices[upgrade_type][current_level]
		price_label.text = "$" + str(price)
		self.disabled = false


func _on_pressed() -> void:
	upgrade_manager._on_UpgradeButton_pressed(upgrade_type)
	self.disabled = true # Prevent multiple clicks until label is refreshed



	pass
