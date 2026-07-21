class_name Game extends Node2D

var GeneratorFactory := preload("res://Generator/Generator.tscn")

@export var nb_generators_start := 3
@onready var rng := RandomNumberGenerator.new()

var generators: Array[Generator]
var foods: Array[Food]


func _ready() -> void:
	foods = []
	%Snake.followed = %Cursor
	%Snake.circled.connect(on_snake_circled)
	%Snake.eated.connect(on_snake_eat)

	for i in nb_generators_start:
		create_generator()

	handle_start()


func handle_start():
	%Cursor.start_invincible()


func add_food(food: Food):
	foods.append(food)
	add_child(food)


func create_generator():
	var viewport_size: Vector2 = get_viewport_rect().size
	var screen_width: float = viewport_size.x
	var screen_height: float = viewport_size.y
	var position := Vector2(
		Globals.rng.randi_range(0, screen_width), Globals.rng.randi_range(0, screen_height)
	)
	var generator := GeneratorFactory.instantiate()
	generator.global_position = position
	generators.append(generator)
	add_child(generator)


func on_snake_circled(snake_parts: Array[Node2D]) -> void:
	var polygon: PackedVector2Array = PackedVector2Array()

	for part in snake_parts:
		polygon.append(part.global_position)

	if not Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()

	var foods_to_remove: Array[Food] = []
	var generators_to_remove: Array[Generator] = []

	for food in foods:
		if Geometry2D.is_point_in_polygon(food.global_position, polygon):
			foods_to_remove.append(food)
			foods.erase(food)
			food.queue_free()

	for generator in generators:
		if Geometry2D.is_point_in_polygon(generator.global_position, polygon):
			generators_to_remove.append(generator)
			generators.erase(generator)
			generator.queue_free()

	add_score(
		(
			foods_to_remove.size() * Globals.food_points
			+ generators_to_remove.size() * Globals.generator_points
		)
	)

	for i in range(1, snake_parts.size()):
		snake_parts[i].queue_free()


func add_score(amount: int):
	var main: Main = get_parent()
	main.add_score(amount)


func on_snake_eat(food: Food):
	var main: Main = get_parent()
	main.add_score(10)
	foods.erase(food)
	food.queue_free()


func _on_cursor_hit() -> void:
	if Globals.nb_lifes > 1:
		Globals.remove_life()
	else:
		get_tree().change_scene_to_file("res://GameOver/GameOver.tscn")


func _on_timer_timeout() -> void:
	if foods.is_empty():
		for food in foods:
			food.change_direction()
	elif generators.is_empty():
		create_generator()

	var random = Globals.rng.randi_range(0, 99)

	if random < 5:
		create_generator()
	elif random < 40:
		for food in foods:
			food.dash()
	elif random < 70:
		for food in foods:
			food.change_direction()
	else:
		for generator in generators:
			generator.generate_food()
