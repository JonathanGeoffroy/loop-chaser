class_name Main
extends Node2D


func _ready() -> void:
	Globals.reset()
	%HUD.set_score(Globals.score)


func add_score(add_score: int, position: Vector2) -> void:
	var min = 10.0
	var max = 100.0
	Globals.score += add_score
	%HUD.set_score(Globals.score)

	var clamped_score := clampf(add_score, min, max)
	var target_scale_mult := remap(clamped_score, min, max, 1.0, 3.0)
	var target_scale := Vector2.ONE * target_scale_mult
	var color_weight := remap(clamped_score, min, max, 0.0, 1.0)
	var target_color := Color.WHITE.lerp(Color.RED, color_weight)

	var label := Label.new()
	label.text = str("+", add_score)
	label.global_position = position
	label.z_index = 10
	add_child(label)

	label.scale = target_scale
	label.modulate = target_color

	var tween := create_tween()
	tween.set_parallel(true)

	(
		tween
		. tween_property(
			label,
			"global_position",
			Vector2(label.global_position.x, label.global_position.y - 24),
			Globals.animation_speed
		)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)

	(
		tween
		. tween_property(label, "scale", Vector2.ONE, Globals.animation_speed)
		. set_trans(Tween.TRANS_EXPO)
		. set_ease(Tween.EASE_OUT)
	)

	(
		tween
		. tween_property(label, "modulate", Color.WHITE, Globals.animation_speed)
		. set_trans(Tween.TRANS_EXPO)
		. set_ease(Tween.EASE_OUT)
	)

	await tween.finished
	label.queue_free()
