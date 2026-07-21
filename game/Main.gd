class_name Main
extends Node2D


func _ready() -> void:
	Globals.score = 0
	%HUD.set_score(Globals.score)


func add_score(add_score: int) -> void:
	Globals.score += add_score
	%HUD.set_score(Globals.score)
