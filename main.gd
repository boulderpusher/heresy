class_name Main
extends Node3D

@export var n_allies: int
@export var n_enemies: int

enum Team {BLUE, RED}
enum GamePhase {SPAWN, BATTLE, END}

var marine_scene = preload("res://marine/marine.tscn")
var _units: Array[Marine]

var _game_phase: GamePhase
var _unit_to_spawn
var _spawnable: bool

var _camera: Camera3D
var _raycast: RayCast3D

const RAY_LENGTH = 1000

func _ready() -> void:
	_camera = $CameraPivot/Camera3D
	_start_phase(GamePhase.SPAWN)

func _start_phase(phase):
	_game_phase == phase
	if phase == GamePhase.SPAWN:
		$SpawnUI.show()
	if phase == GamePhase.BATTLE:
		$SpawnUI.hide()
		$BattleUI.show()
		for unit in _units:
			unit.activate()
		$CameraPivot.rotate_x(PI / 4)
	if phase == GamePhase.END:
		$BattleUI.hide()
		$EndUI.show()
		
func _on_battle_button_pressed() -> void:
	_start_phase(GamePhase.BATTLE)
	
func _physics_process(delta: float) -> void:
	if _game_phase == GamePhase.SPAWN and _unit_to_spawn:
		_unit_to_mouse()

func _raycast_mouse():
	var mousepos = get_viewport().get_mouse_position()
	var raycast = $MouseRayCast
	
	raycast.position = _camera.project_ray_origin(mousepos)
	raycast.target_position = _camera.project_ray_normal(mousepos) * RAY_LENGTH
	
	raycast.force_raycast_update()
	return raycast

func _unit_to_mouse():
	var raycast = _raycast_mouse()
	var spawn_point = raycast.get_collision_point()
	_unit_to_spawn.position = spawn_point
	_spawnable = raycast.get_collider() == $Ground and _unit_to_spawn in \
			$SpawnArea.get_overlapping_bodies()

func _spawn_marine(location, direction, team):
	var team_group = "blue_team" if team == Team.BLUE else "red_team"
	var marine = marine_scene.instantiate()
	marine.initialize(location, direction)
	add_child(marine)
	marine.set_team(team)
	marine.add_to_group(team_group)
	_units.append(marine)
	return marine

func _on_spawn_marine_button_pressed() -> void:
	var marine = _spawn_marine(Vector3(0, 0, 0), Vector3(0, 0, -1), Team.BLUE)
	_unit_to_spawn = marine
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if _game_phase == GamePhase.SPAWN:
			if _spawnable: # place unit
				_units.append(_unit_to_spawn)
				_unit_to_spawn = null
				_spawnable = false
			elif not _unit_to_spawn: # move unit
				var raycast = _raycast_mouse()
				var collider = raycast.get_collider()
				if collider is Marine:
					_unit_to_spawn = collider
