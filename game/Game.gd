extends Node2D

var Food = preload("res://food/Food.tscn")

@export var nb_food_start := 10
@onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	%Snake.followed = %Cursor

	for i in nb_food_start:
		on_generate_food()


func on_generate_food() -> void:
	var food: Food = Food.instantiate()
	food.position = Vector2(rng.randf_range(0, 800), rng.randf_range(0, 600))
	add_child(food)
