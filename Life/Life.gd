extends Area2D


func disable():
	$CollisionShape2D.set_deferred("disabled", true)
