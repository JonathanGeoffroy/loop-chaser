class_name Follower
extends Node

@export var max_speed: float = 400.0
@export var max_rotation_speed: float = 5.0

var parent: Node2D
var target_angle: float


func _ready() -> void:
	parent = get_parent() as Node2D


func move_towards(target_position: Vector2, delta: float) -> void:
	target_angle = parent.global_position.angle_to_point(target_position)
	parent.global_rotation = rotate_toward(
		parent.global_rotation, target_angle, max_rotation_speed * delta
	)

	var move_direction = Vector2.RIGHT.rotated(parent.global_rotation)
	parent.global_position += move_direction * max_speed * delta
