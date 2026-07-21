extends Node


func get_polygon_center(poly: PackedVector2Array) -> Vector2:
	if poly.is_empty():
		return Vector2.ZERO

	var sum := Vector2.ZERO
	for point in poly:
		sum += point

	return sum / poly.size()
