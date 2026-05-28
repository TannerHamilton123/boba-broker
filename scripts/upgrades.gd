class_name UpgradeData

# Index = current level (what you are about to buy).
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

# Cost in dollars for each level purchase (parallel to labels arrays).
const costs: Dictionary = {
	"Storage":    [75,  150, 300, 500],
	"Ingredient": [100, 150, 225],
	"WaitTime":   [50,  100, 200, 350],
	"Popularity": [100, 200, 400, 750],
	"Supply":     [75,  175, 350, 600]
}
