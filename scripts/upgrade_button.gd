extends Button

var upgrade_type: String = ""
var current_level: int = 0

var upgrade_manager

'''
Sets button text from UpgradeData based on
upgrade_type and current_level
'''
func _ready() -> void:
	upgrade_manager = get_tree().root.get_node("main/UpgradeManager")

	upgrade_type = self.name
	refresh_label()


func refresh_label() -> void:
	if upgrade_type == "":
		return
	var levels: Array = UpgradeData.labels[upgrade_type]
	var costs: Array = UpgradeData.costs[upgrade_type]
	if current_level >= levels.size():
		text = upgrade_type + ": Maxed Out"
	else:
		text = levels[current_level] + "  ($" + str(costs[current_level]) + ")"


func _on_pressed() -> void:
	upgrade_manager._on_UpgradeButton_pressed(upgrade_type)


	pass
