extends ColorRect
var _dragging = false
var destination: Vector2
var starting_position: Vector2
var _last_position: Vector2
var used_ingredients = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
	starting_position = position
	_last_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for ingredient in used_ingredients:
		fill_up(ingredient)
	
	
	_last_position = global_position
	if _dragging:
		if global_position.distance_to(destination) > 10.0:
			position = lerp(position, destination, 0.2) + Vector2(-10, -10) # Add a slight upward offset for a more dynamic feel
			# for ball in get_tree().get_nodes_in_group("boba_balls"):
			# 	ball.linear_velocity += cup_velocity 

	elif not _dragging:
		if global_position.distance_to(starting_position) > 10.0:
			position = lerp(position, starting_position, 0.2)
			
		else:
			position = starting_position
	
	
func _input(event: InputEvent) -> void:
	if get_viewport().gui_is_dragging():
		return

	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if _is_over_cup(mouse_pos):
			print("Mouse clicked over the cup at: ", mouse_pos)
			_dragging = true
			destination = get_global_mouse_position()
	elif event is InputEventMouseButton and not event.pressed:
		if _dragging:
			print("Mouse released, stopping drag.")
			_dragging = false

	elif event is InputEventMouseMotion and _dragging:
		destination = get_global_mouse_position()


func _is_over_cup(click_position: Vector2) -> bool:
	var cup_rect = $"Area2D/CollisionShape2D".shape.get_rect()
	cup_rect.position += $"Area2D/CollisionShape2D".global_position
	print("Checking if click at ", click_position, " is over cup rect: ", cup_rect)
	return cup_rect.has_point(click_position)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
		return true


func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("Attempting to drop data: ", data, " at position: ", at_position)
	if _can_drop_data(at_position,data):
		match data:
			"tea":
				
				if get_tree().current_scene.tea_quantity > 0:
					used_ingredients.append("tea")
					$"tea".scale.y = 0.1
					$"tea".visible = true
					get_tree().current_scene.tea_quantity -= 1
			"milk":
				if get_tree().current_scene.milk_quantity > 0:
					used_ingredients.append("milk")
					$"milk".scale.y = 0.1
					$"milk".visible = true
					get_tree().current_scene.milk_quantity -= 1
			"pearls":
				if get_tree().current_scene.pearls_quantity > 0:
					used_ingredients.append("pearls")
					$"pearls".visible = true
					get_tree().current_scene.pearls_quantity -= 1
		get_tree().current_scene.update_ui()

		print("Current ingredients in cup: ", used_ingredients)

			
func reset():
	print("Resetting cup to empty state.")
	used_ingredients.clear()
	$"tea".visible = false
	$"pearls".visible = false
	$"milk".visible = false

func fill_up(ingredient):
	if ingredient == "milk":
		if $"milk".scale.y < 1:
			$"milk".scale.y += 0.01
	if ingredient == "tea":
		if $"tea".scale.y < 1:
			$"tea".scale.y += 0.01
