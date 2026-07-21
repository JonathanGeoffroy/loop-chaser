class_name Cursor
extends Area2D

signal hit

var is_invincible := false


func _process(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	global_position = target_pos


func start_invincible():
	is_invincible = true
	$AnimationPlayer.play("invincibility")
	$CollisionShape2D.set_deferred("disabled", true)
	#await get_tree().create_timer(2.0).timeout
	#$AnimationPlayer.stop()
	#$CollisionShape2D.set_deferred("disabled", false)


func get_hit():
	start_invincible()
	hit.emit()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("chaser"):
		get_hit()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("chaser"):
		get_hit()
