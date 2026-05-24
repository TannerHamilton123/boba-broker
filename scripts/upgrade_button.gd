extends Button

var upgrade_type: String = ""
var current_level: int = 0


'''
Sets button text from UpgradeData based on
upgrade_type and current_level
'''
func _ready() -> void:
	upgrade_type = self.name
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
		text = upgrade_type + ": Maxed Out"
	else:
		text = levels[current_level]


func _on_pressed() -> void:
	pass
