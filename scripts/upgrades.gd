class_name UpgradeData

'''
Button label for each upgrade at each level.
Index = current level (what you are about to buy).
Add more strings to extend the max level.
'''
const labels: Dictionary = {
	"Storage": [
		"Extra Shelf",
		"Storage Rack",
		"Walk-in Cooler",
		"Warehouse Annex"
	],
	"Ingredient": [
		"Taro",
		"Lemon",
		"Strawberry",
	],
	"WaitTime": [
		"Comfy Stools",
		"Chill Playlist",
		"Free Sample Station",
		"Loyalty Punch Card"
	],
	"Popularity": [
		"Sidewalk Chalkboard",
		"Social Media Page",
		"Local Blog Feature",
		"Influencer Partnership"
	],
	"Supply": [
		"Bulk Order Discount",
		"Supplier Contract",
		"Direct Farm Import",
		"Co-op Membership"
	]
}

const prices = {
	"Storage": [100, 200, 400, 800],
	"Ingredient": [150, 300, 600],
	"WaitTime": [120, 240, 480, 960],
	"Popularity": [130, 260, 520, 1040],
	"Supply": [110, 220, 440, 880]
}