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
		var generator = create_generator()
		for g in range(0, 3):
			generator.generate_food();
	handle_start()


func handle_start():
	%Cursor.start_invincible()


func add_food(food: Food):
	foods.append(food)
	add_child(food)
	food.exited_screen.connect(remove_food);

func remove_food(food: Food) -> void:
	foods.erase(food);
	food.queue_free();

func create_generator() -> Generator:
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
	
	return generator


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
			food.disable()

	for generator in generators:
		if Geometry2D.is_point_in_polygon(generator.global_position, polygon):
			generators_to_remove.append(generator)
			generators.erase(generator)
			generator.disable()

	var items = snake_parts + generators_to_remove + foods_to_remove
	items.remove_at(0)  # Remove snake head
	var center: Vector2 = Polygon.get_polygon_center(polygon)
	var tween := create_tween().set_parallel(true)
	for item in items:
		if is_instance_valid(item):
			(
				tween
				. tween_property(item, "global_position", center, Globals.animation_speed)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_IN)
			)

	await tween.finished

	for item in items:
		if is_instance_valid(item):
			item.queue_free()

	add_score(
		(
			foods_to_remove.size() * Globals.food_points
			+ generators_to_remove.size() * Globals.generator_points
		),
		center
	)


func add_score(amount: int, position: Vector2):
	if amount > 0:
		var main: Main = get_parent()
		main.add_score(amount, position)
		$PointsStreamPlayer.play()

func on_snake_eat(food: Food):
	add_score(10, food.global_position)
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
