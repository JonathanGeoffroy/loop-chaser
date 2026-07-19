class_name SnakeHead
extends Area2D

signal eated
signal tail_hitted(snakePart: SnakePart)

func on_colide(area: Area2D) -> void:
	if area.is_in_group("food"):
		eated.emit()
		area.queue_free()

	elif area.is_in_group("snakePart"):
		tail_hitted.emit(area);
