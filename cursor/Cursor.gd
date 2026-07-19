class_name Cursor
extends Area2D


func _process(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	# $Follower.move_towards(target_pos, delta)
	global_position = target_pos
