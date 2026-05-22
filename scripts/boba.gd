extends ColorRect

var used_ingredients = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(at_position, data):
		print("Dropped ", data, " at ", at_position)
		match data:
			"tea":
				self.color = Color(46, 0.8, 1) # Light brown for tea
				used_ingredients.append("tea")
			"milk":
				self.color = Color(1, 1, 1) # White for milk
				used_ingredients.append("milk")
			"pearls":
				self.color = Color(0.2, 0.2, 0.2) # Dark gray for boba
				used_ingredients.append("pearls")
		print("Updated color to: ", self.color)