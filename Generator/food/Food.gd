class_name Food
extends CharacterBody2D

signal exited_screen(food: Food);

var direction := 0.0
var is_moving: bool = false

@export var move_distance: float = 100.0
@export var move_duration: float = 0.2

var angle := 0.0


func _ready() -> void:
	var scale_factor := Globals.food_size / 128.0
	scale = Vector2(scale_factor, scale_factor)
	$CollisionShape2D.disabled = true;
	get_tree().create_timer(0.5).timeout.connect(enable_collision)

func enable_collision():
	$CollisionShape2D.disabled = false;
		
func change_direction():
	angle = Globals.rng.randf_range(0, TAU)
	var tween := create_tween().set_parallel(true)
	(
		tween
		. tween_property($Sprite2D, "rotation", angle, Globals.animation_speed)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)


func dash() -> void:
	if is_moving:
		return

	is_moving = true

	var direction := Vector2.from_angle(angle)
	var required_speed := move_distance / move_duration
	velocity = direction * required_speed

	await get_tree().create_timer(move_duration).timeout
	velocity = Vector2.ZERO
	is_moving = false


func _physics_process(_delta: float) -> void:
	if is_moving:
		move_and_slide()


func appears():
	change_direction()
	var offset: Vector2 = Vector2.from_angle(angle) * 128.0
	global_position += offset


func disable():
	$CollisionShape2D.disabled = true


func _on_exit_screen() -> void:
	exited_screen.emit(self);
