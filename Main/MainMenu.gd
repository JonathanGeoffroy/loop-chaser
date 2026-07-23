extends Control



func handle_token():
	var tokenString = %LineEdit.text;
	
	var token = Token.deserialize(tokenString)
	if token != null:
		Globals.set_seed(token.seed)
		Globals.chasing_name = token.username
		Globals.chasing_score = token.score
		%ChasingUsername.text = Globals.chasing_name
		%ChasingScore.text = str(Globals.chasing_score)
		%ChasingContainer.visible = true
		%CodeContainer.visible = false
	else:
		%ChasingContainer.visible = false
		%CodeContainer.visible = true

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main.tscn")


func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://HowToPlay/HowToPlay.tscn")


func _on_code_submitted() -> void:
	handle_token();
