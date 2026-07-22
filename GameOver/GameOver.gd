extends Control

var username_regexp = RegEx.new()
var base_url: String;

func _ready() -> void:
	username_regexp.compile("[^a-zA-Z0-9_]")
	base_url = get_base_url()

	%UserName.text_changed.connect(_on_username_changed)

	%Highscore.text = str(Globals.score)
	%UserName.text = Globals.user_name
	%URL.text = compute_url()
	
	if Globals.chasing_score > 0:
		%ChasingLabel.text = Globals.chasing_name;
		%ChasingScoreLabel.text = Globals.chasing_score;
		
	var user_play_alone := Globals.chasing_score == 0
	var user_win := user_play_alone or Globals.score > Globals.chasing_score;
	
	%ChasingScoreContainer.visible = !user_play_alone;
	%ChasingScoreSpacer.visible = !user_play_alone;
	
	var container_to_animate = %PlayerScoreContainer if user_win else %ChasingScoreLabel;
	for child in container_to_animate.get_children():
		animate(child);
		
	if Globals.chasing_score:
		%AnimationPlayer.get_animation("winner");
	
func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(%URL.text)
	%CopyButton.text = "Copied!"


func _on_retry_button_pressed() -> void:
	Globals.score = 0
	get_tree().change_scene_to_file("res://game/Main.tscn")


func compute_url() -> String:
	var token := Token.serialize(Globals.seed, Globals.score, Globals.user_name)
	return str(base_url, "?", token)


func get_base_url() -> String:
	if OS.get_name() == "Web":
		var referrer = JavaScriptBridge.eval("document.referrer", true)
		if referrer != null and str(referrer) != "":
			return str(referrer)

		var local_href = JavaScriptBridge.eval("window.location.href", true)
		if local_href != null and str(local_href) != "":
			return str(local_href)
	return ""


func _on_username_changed(new_text: String) -> void:
	var text: String = username_regexp.sub(new_text, "", true)
	if text != new_text:
		%UserName.text = text
		%UserName.caret_column = text.length()

	Globals.user_name = text
	%URL.text = compute_url()


func animate(label: Label) -> void:
	label.pivot_offset = label.size / 2.0
	
	var tween := create_tween().set_parallel(true).set_loops();
	
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate", Color.GOLD, 0.15)
	
	tween.chain().set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2)
