extends Control


func _ready():
	var token := Token.compute_token()

	if token != null:
		Globals.set_seed(token.seed)
		Globals.chasing_name = token.user_name
		Globals.chasing_score = token.score
		
	if Globals.chasing_score > 0:
		%ChasingUsername.text = Globals.chasing_name
		%ChasingScore.text = str(Globals.chasing_score)
		%ChasingContainer.visible = true
	else:
		%ChasingContainer.visible = false


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main.tscn")
