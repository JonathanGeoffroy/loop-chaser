extends Control

var username_regexp = RegEx.new()


func _ready() -> void:
	username_regexp.compile("[^a-zA-Z0-9_]")
	var token := compute_token()
	if token != null:
		Globals.seed = token.seed
		Globals.chasing_name = token.user_name
		Globals.chasing_score = token.score

	elif Globals.seed == 0:
		Globals.seed = randi()

	%Highscore.text = str(Globals.score)
	%UserName.text = Globals.user_name
	%URL.text = compute_url()


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(%URL.text)
	%CopyButton.text = "Copied!"


func _on_retry_button_pressed() -> void:
	Globals.score = 0
	get_tree().change_scene_to_file("res://game/Game.tscn")


func compute_url() -> String:
	var url := get_base_url()
	var token := Token.serialize(Globals.seed, Globals.score, Globals.user_name)
	return str(url, "?", token)


func get_base_url() -> String:
	if OS.get_name() == "Web":
		var referrer = JavaScriptBridge.eval("document.referrer", true)
		if referrer != null and str(referrer) != "":
			return str(referrer)

		var local_href = JavaScriptBridge.eval("window.location.href", true)
		if local_href != null and str(local_href) != "":
			return str(local_href)
	return ""


func _on_username_changed() -> void:
	var text: String = username_regexp.sub(%UserName.text, "", true)
	if text != %UserName.text:
		%UserName.text = text
		%UserName.caret_column = text.length()

	Globals.user_name = text
	%URL.text = compute_url()


func compute_token() -> TokenValue:
	var url_token = compute_url_token()
	if url_token != "":
		var token = Token.deserialize(url_token)
		return token
	return null


func compute_url_token() -> String:
	if OS.get_name() == "Web":
		var token_script := """
		(function() {
			var ref = document.referrer;
			if (ref) {
				var url = new URL(ref);
				var t = url.searchParams.get("token");
				if (t) return t;
			}
			var localUrl = new URL(window.location.href);
			return localUrl.searchParams.get("token") || "";
		})();
		"""

		var result = JavaScriptBridge.eval(token_script, true)
		if result != null and str(result) != "":
			return str(result)

	return ""
