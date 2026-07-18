class_name Snake
extends Node2D

var SnakeHead := preload("res://snake/SnakeHead.tscn")

@export var max_speed: float = 400.0
@export var max_rotation_speed: float = 5.0
@export var follow_distance: float = 40.0
@export var segments: Array[Node2D] = []


func _ready() -> void:
	append(SnakeHead.instantiate())


func _process(delta: float) -> void:
	if segments.is_empty():
		return

	var head = segments[0]
	var target_pos = get_global_mouse_position()

	if head.global_position.distance_to(target_pos) > 5.0:
		var target_angle = head.global_position.angle_to_point(target_pos)

		head.global_rotation = rotate_toward(
			head.global_rotation, target_angle, max_rotation_speed * delta
		)

		var move_direction = Vector2.RIGHT.rotated(head.global_rotation)
		head.global_position += move_direction * max_speed * delta

	for i in range(1, segments.size()):
		var leader = segments[i - 1]
		var follower = segments[i]

		var to_leader = leader.global_position - follower.global_position
		var current_dist = to_leader.length()

		if current_dist > 0.0:
			var direction = to_leader.normalized()
			follower.global_position = leader.global_position - (direction * follow_distance)
			follower.global_rotation = direction.angle()


func append(segment: Node2D) -> void:
	segments.append(segment)
	add_child(segment)
