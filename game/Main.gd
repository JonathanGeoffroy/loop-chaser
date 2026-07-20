class_name Main
extends Node2D

var score := 0


func add_score(add_score: int) -> void:
	score += add_score
	%HUD.set_score(score)
