class_name SnakeHead
extends Area2D

signal eated


func on_colide(area: Area2D) -> void:
	if area.is_in_group("food"):
		eated.emit()
		area.queue_free()
