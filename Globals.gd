extends Node

signal life_changed(nb_life: int)

const part_size := 48
const food_size := 48

const generator_points := 50
const food_points := 10

const animation_speed := 0.3

var nb_lifes := 3
var seed := 0
var score := 0
var user_name := "Highscore_Chaser"
var rng := RandomNumberGenerator.new()

var chasing_score := 0
var chasing_name := ""


func set_seed(seed: int):
	self.seed = seed
	rng.seed = seed


func reset():
	nb_lifes = 3
	score = 0
	seed = randi()


func remove_life():
	if nb_lifes >= 1:
		nb_lifes -= 1
		life_changed.emit(nb_lifes)
