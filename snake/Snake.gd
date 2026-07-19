class_name Snake
extends Node2D

var SnakeHead := preload("res://snake/SnakeHead.tscn")
var SnakePart := preload("res://snake/SnakePart.tscn")

var follow_distance: float = Globals.part_size * 2. / 3.
var segments: Array[Node2D] = []

@onready var follower = %Follower
var followed: Node2D


func _ready() -> void:
	var head: SnakeHead = SnakeHead.instantiate()
	append(head)
	head.eated.connect(on_eat)


func _process(delta: float) -> void:
	if followed != null:
		follower.move_towards(followed.global_position, delta)

	move_body()


func move_body() -> void:
	for i in range(1, segments.size()):
		var previous = segments[i - 1]
		var follower = segments[i]

		var position = previous.global_position - follower.global_position
		var current_dist = position.length()

		var direction = position.normalized()
		follower.global_position = previous.global_position - (direction * follow_distance)
		follower.global_rotation = direction.angle()


func append(segment: Node2D) -> void:
	if !segments.is_empty():
		var last_segment := segments[segments.size() - 1]
		var spawn_pos = last_segment.global_position + (Vector2(-1, 0) * follow_distance)
		segment.global_position = spawn_pos

	segments.append(segment)
	add_child(segment)


func on_eat() -> void:
	var segment := SnakePart.instantiate()
	append(segment)
