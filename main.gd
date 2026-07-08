class_name Main
extends Node3D

@export var n_allies: int
@export var n_enemies: int

enum Team {BLUE, RED}

var marine_scene = preload("res://marine/marine.tscn")
var _units: Array[Marine]

var _unit_to_spawn
var _spawnable: bool

var _camera: Camera3D
var _raycast: RayCast3D

const RAY_LENGTH = 1000

func _ready() -> void:
	_camera = $CameraPivot/Camera3D
	_raycast = $RayCast3D

func _physics_process(delta: float) -> void:
	if _unit_to_spawn:
		var mousepos = get_viewport().get_mouse_position()
		_raycast.position = _camera.project_ray_origin(mousepos)
		_raycast.target_position = _camera.project_ray_normal(mousepos) * RAY_LENGTH
		_raycast.force_raycast_update()
		if _raycast.is_colliding():
			var collider = _raycast.get_collider()
			if collider == $Ground:
				var spawn_point = _raycast.get_collision_point()
				_unit_to_spawn.position = spawn_point
				if _unit_to_spawn in $SpawnArea.get_overlapping_bodies():
					_unit_to_spawn.show()
					_spawnable = true
				else:
					_unit_to_spawn.hide()
					_spawnable = false
		else:
			_unit_to_spawn.hide()
			_spawnable = false

func _on_spawn_marine_button_pressed() -> void:
	var marine = marine_scene.instantiate()
	add_child(marine)
	marine.set_team(Team.BLUE)
	marine.hide()
	_unit_to_spawn = marine
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if _spawnable:
			_unit_to_spawn.add_to_group("blue_team")
			_units.append(_unit_to_spawn)
			_unit_to_spawn = null
			_spawnable = false

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
