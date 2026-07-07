class_name Main
extends Node

@export var n_allies: int
@export var n_enemies: int

enum Team {BLUE, RED}

var marine_scene = preload("res://marine/marine.tscn")
var _units: Array[Marine]

func _ready() -> void:
	pass
	#_spawn_armies()

func _process(delta: float) -> void:
	pass

func _spawn_marine_to_cursor():
	var marine = marine_scene.instantiate()
	marine.initialize(get_viewport().get_mouse_position(), Vector3(0, 0, 1))
	marine.set_team(Team.BLUE)
	marine.add_to_group("blue_team")
	add_child(marine)


func _spawn_armies():
	var spawn_location_blue = $SpawnPathBlue/SpawnLocation
	for i in range(n_allies):
		spawn_location_blue.progress_ratio = float(i + 1) / float(n_allies + 1)
		_spawn_marine(spawn_location_blue.position, Vector3(1, 0, 0), Team.BLUE)
		
	var spawn_location_red = $SpawnPathRed/SpawnLocation
	for i in range(n_enemies):
		spawn_location_red.progress_ratio = float(i + 1) / float(n_enemies + 1)
		_spawn_marine(spawn_location_red.position, Vector3(-1, 0, 0), Team.RED)
		
func _spawn_marine(location, direction, team):
	var team_group = "blue_team" if team == Team.BLUE else "red_team"
	var marine = marine_scene.instantiate()
	marine.initialize(location, direction)
	add_child(marine)
	marine.set_team(team)
	marine.add_to_group(team_group)
	_units.append(marine)
