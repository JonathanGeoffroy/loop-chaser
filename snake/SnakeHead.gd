extends Area2D


func on_colide(area: Area2D) -> void:
	if area.is_in_group("food"):
		area.queue_free()
