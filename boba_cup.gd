extends Node2D
var _dragging = false
var destination: Vector2
var starting_position: Vector2
var _last_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = position
	_last_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_last_position = global_position
	var cup_velocity = (global_position - _last_position) / delta

	if _dragging:
		if global_position.distance_to(destination) > 10.0:
			position = lerp(position, destination, 0.2)
			
			
	
			for ball in get_tree().get_nodes_in_group("boba_balls"):
				ball.linear_velocity += cup_velocity 

	elif not _dragging:
		if global_position.distance_to(starting_position) > 10.0:
			position = lerp(position, starting_position, 0.2)
			print("Returning to starting position: ", position)
		else:
			position = starting_position
	
	

func _input(event: InputEvent) -> void:
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
