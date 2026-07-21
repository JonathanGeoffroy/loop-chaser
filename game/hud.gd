extends CanvasLayer

var LifeFactory = preload("res://Life/Life.tscn")

var tween: Tween


func _ready() -> void:
	tween = create_tween().set_parallel(true)

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
	if tween and tween.is_running():
		tween.kill()
	%Score.scale = Vector2(1.4, 1.4)
	%Score.modulate = Color.RED

	tween = create_tween().set_parallel(true)

	(
		tween
		. tween_property(%Score, "scale", Vector2.ONE, Globals.animation_speed)
		. set_trans(Tween.TRANS_EXPO)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween
		. tween_property(%Score, "modulate", Color.WHITE, Globals.animation_speed)
		. set_trans(Tween.TRANS_EXPO)
		. set_ease(Tween.EASE_OUT)
	)


func on_life_changed(life: int) -> void:
	for child in %Lifes.get_children():
		%Lifes.remove_child(child)

	for i in range(0, life):
		var life_view: Area2D = LifeFactory.instantiate()
		life_view.disable()
		life_view.position = Vector2(i * 48, 24)
		%Lifes.add_child(life_view)
