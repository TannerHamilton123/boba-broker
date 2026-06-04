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
		"Strawberry",
		"Lemon"
		
	],
	"WaitTime": [
		"Comfy Couches",
		"Chill Playlist",
		"Selfie Wall",
		"Big Benny Plushie"
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
	"Storage": [10, 20, 30, 40],
	"Ingredient": [10, 15, 20],
	"WaitTime": [10, 20, 30, 40],
	"Popularity": [10, 20, 30, 40],
	"Supply": [10, 20, 30, 40]
}