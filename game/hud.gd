extends CanvasLayer

var LifeFactory = preload("res://Life/Life.tscn")


func _ready() -> void:
	Globals.life_changed.connect(on_life_changed)
	on_life_changed(Globals.nb_lifes)

	if Globals.chasing_score > 0:
		%ChasingScoreContainer.visible = true
		%ChasingScore.text = str(Globals.chasing_score)
		%ChasingUsername.text = str(Globals.chasing_name, ": ")
	else:
		%ChasingScoreContainer.visible = true


func set_score(score: int) -> void:
	%Score.text = str(score)


func on_life_changed(life: int) -> void:
	for child in %Lifes.get_children():
		%Lifes.remove_child(child)

	for i in range(0, life):
		var life_view: Area2D = LifeFactory.instantiate()
		life_view.disable()
		life_view.position = Vector2(i * 48, 24)
		%Lifes.add_child(life_view)
