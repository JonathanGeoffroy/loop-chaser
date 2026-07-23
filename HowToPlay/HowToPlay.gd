extends Node2D

var HowToPlayer = preload("res://HowToPlay/HowToPlayer.tscn");
var HowToEnnemies = preload("res://HowToPlay/HowToEnnemies.tscn");
var HowToFrog = preload("res://HowToPlay/HowToFrog.tscn");
var HowToCircle = preload("res://HowToPlay/HowToCircle.tscn")
var HowToLife = preload("res://HowToPlay/HowToLife.tscn");

var timeline = [HowToPlayer, HowToEnnemies, HowToFrog, HowToCircle, HowToLife];
var current := 0;
var current_node: Node2D;

func _ready() -> void:
	current = 0;
	load_howto()
	

func _process(delta: float) -> void:
	pass


func on_next() -> void:
	if current == timeline.size() - 1:
		get_tree().change_scene_to_file("res://Main/MainMenu.tscn");
	else:
		current += 1;
		load_howto()
		
func load_howto():
	if current_node:
		remove_child(current_node);
	current_node = timeline[current].instantiate();
	add_child(current_node);
