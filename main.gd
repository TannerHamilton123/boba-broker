extends Node2D
var tea_quantity: int = 0
var pearls_quantity: int = 0
var milk_quantity: int = 0
var TeaPrice: float = 1.0
var PearlPrice: float = 1.0
var MilkPrice: float = 1.0
var player_balance: float = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	TeaPrice = snappedf($"UI/TeaPrice".value, 0.01)
	PearlPrice = snappedf($"UI/PearlPrice".value, 0.01)
	MilkPrice = snappedf($"UI/MilkPrice".value, 0.01)

	$UI/PlayerBalance.text = "$%.2f" % player_balance
	if player_balance <= 0:
		print("game over")
		$UI/GameOver.visible = true

	pass

func _on_bubble_clicked(ingredient: String, price: float) -> void:
	match ingredient:
		"tea":
			tea_quantity += 1
		"pearls":
			pearls_quantity += 1
		"milk":
			milk_quantity += 1
	player_balance -= price
	update_ui()

func update_ui() -> void:
	$"UI/tea_quantity".text = "Tea: " + str(tea_quantity)
	$"UI/pearl_quantity".text = "Pearls: " + str(pearls_quantity)
	$"UI/milk_quantity".text = "Milk: " + str(milk_quantity)



func _on_Ingredient_drag_data_received(position: Vector2, data: Variant) -> void:
	print("Received drag data: ", data, " at position: ", position)
	if data == "tea":
		tea_quantity += 1
	elif data == "pearls":
		pearls_quantity += 1
	elif data == "milk":
		milk_quantity += 1
	update_ui()