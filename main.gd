class_name Main
extends Node

@export var n_allies: int
@export var n_enemies: int

enum Team {BLUE, RED}

var marine_scene = preload("res://marine/marine.tscn")
var _allies: Array[Marine]
var _enemies: Array[Marine]

func _ready() -> void:
	for i in range(n_allies):
		var ally = marine_scene.instantiate()
		add_child(ally)
		ally.set_team(Team.BLUE)
		_allies.append(ally)
	for i in range(n_enemies):
		var enemy = marine_scene.instantiate()
		add_child(enemy)
		enemy.set_team(Team.RED)
		_enemies.append(enemy)
	for ally in _allies:
		ally.walk(Vector3.FORWARD.rotated(Vector3.UP, randf_range(-2*PI, 2*PI)))
	for enemy in _enemies:
		enemy.walk(Vector3.FORWARD.rotated(Vector3.UP, randf_range(-2*PI, 2*PI)))

func _process(delta: float) -> void:
	pass
