class_name MapModel
extends RefCounted


class Line:
	var start: Vector2
	var end: Vector2

	func _init(start: Vector2, end: Vector2) -> void:
		self.start = start
		self.end = end

	func _to_string() -> String:
		var props = []

		for prop in get_property_list():
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				var prop_name = prop.name
				var prop_val = get(prop_name)
				props.append("%s: %s" % [prop_name, str(prop_val)])

		return "[%s < %s >]" % [get_class(), ", ".join(props)]


class Cross:
	var position: Vector2


var lines: Array[Line]
var crosses: Array[Cross]


func _init() -> void:
	lines = []
	crosses = []
