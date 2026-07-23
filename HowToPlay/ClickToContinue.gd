extends Label

signal next;

func _ready():
	$AnimationPlayer.play("Blink");
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			next.emit()
