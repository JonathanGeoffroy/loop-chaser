class_name Generator
extends Node2D

const FoodFactory := preload("res://Generator/food/Food.tscn")


func _ready() -> void:
	var scale_factor = Globals.part_size / 128.0
	scale = Vector2(scale_factor, scale_factor)


func generate_food():
	var food: Food = FoodFactory.instantiate()
	food.global_position = global_position
	food.appears()
	var game: Game = get_parent()
	game.add_food(food)
