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
	"Storage": [10, 20, 30, 50],
	"Ingredient": [10, 20, 30],
	"WaitTime": [30, 60, 120, 240],
	"Popularity": [30, 40, 60, 80],
	"Supply": [10, 20, 30, 40]
}