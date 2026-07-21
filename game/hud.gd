extends CanvasLayer


func _ready() -> void:
	if Globals.chasing_score > 0:
		%ChasingScoreContainer.visible = true
		%ChasingScore.text = str(Globals.chasing_score)
		%ChasingUsername.text = str(Globals.chasing_name, ": ")
	else:
		%ChasingScoreContainer.visible = true


func set_score(score: int) -> void:
	%Score.text = str(score)
