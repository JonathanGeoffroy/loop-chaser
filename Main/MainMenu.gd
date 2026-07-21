extends Control


func _ready():
	if Globals.chasing_score > 0:
		%ChasingUsername.text = Globals.chasing_name
		%ChasingScore.text = str(Globals.chasing_score)
		%ChasingContainer.visible = true
	else:
		%ChasingContainer.visible = false


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main.tscn")
