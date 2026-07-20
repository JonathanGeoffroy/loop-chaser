extends Node2D

var Food = preload("res://food/Food.tscn")

@export var nb_food_start := 10
@onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	%Snake.followed = %Cursor
	%Snake.circled.connect(on_snake_circled)
	%Snake.eated.connect(on_snake_eat)

	for i in nb_food_start:
		on_generate_food()


func on_generate_food() -> void:
	var food: Food = Food.instantiate()
	food.position = Vector2(rng.randf_range(0, 800), rng.randf_range(0, 600))
	add_child(food)


func on_snake_circled(snake_parts: Array[Node2D]) -> void:
	var polygon: PackedVector2Array = PackedVector2Array()

	for part in snake_parts:
		polygon.append(part.global_position)

	if not Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()

	for child in get_children():
		if child.is_in_group("food"):
			var food: Food = child
			if Geometry2D.is_point_in_polygon(food.global_position, polygon):
				# TODO JGE compute multiplicator
				on_snake_eat(food)

	for i in range(1, snake_parts.size()):
		snake_parts[i].queue_free()


func on_snake_eat(food: Food):
	var main: Main = get_parent()
	main.add_score(10)
	food.queue_free()
