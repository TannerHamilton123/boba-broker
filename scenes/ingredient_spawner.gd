extends Node

var ingredients = ["tea", "milk", "pearls", "taro", "strawberry", "lemon"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Spawn ingredients from top of screen to fall down the screen, and then queue_free() when they reach the bottom

@onready var milk_scene: PackedScene = preload("res://scenes/milk.tscn")
@onready var tea_scene: PackedScene = preload("res://scenes/tea.tscn")
@onready var pearls_scene: PackedScene = preload("res://scenes/pearls.tscn")
@onready var taro_scene: PackedScene = preload("res://scenes/taro.tscn")
@onready var strawberry_scene: PackedScene = preload("res://scenes/strawberry.tscn")
@onready var lemon_scene: PackedScene = preload("res://scenes/lemon.tscn")	

func spawn_ingredient(ingredient_name: String) -> void:
	var ingredient_scene: PackedScene
	match ingredient_name:
		"milk":
			ingredient_scene = milk_scene
		"tea":
			ingredient_scene = tea_scene
		"pearls":
			ingredient_scene = pearls_scene
		"taro":
			ingredient_scene = taro_scene
		"strawberry":
			ingredient_scene = strawberry_scene
		"lemon":
			ingredient_scene = lemon_scene
	var ingredient_instance = ingredient_scene.instantiate()
	add_child(ingredient_instance)
	#spawn between x = 50-200 or 400-750, and y = -50
	var x_position: float = randf_range(50, 200) if randf() < 0.5 else randf_range(400, 750)
	ingredient_instance.position = Vector2(x_position, -50)


func _on_timer_timeout() -> void:
	#spawn an ingredient based on the probabilities in the game_ingredients dictionary
	var random_ingredient = ingredients[randi() % ingredients.size()]
	spawn_ingredient(random_ingredient)