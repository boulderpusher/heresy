class_name Main
extends Node3D

enum Team {BLUE, RED}
enum GamePhase {SPAWN, BATTLE, END}

var marine_scene = preload("res://marine/marine.tscn")
var _units: Array[Marine]
var _n_units: Dictionary

var _game_phase: GamePhase
@export var _current_battle: int
var _victor: Team
var _unit_to_spawn
var _spawnable: bool

var _camera: Camera3D
var _raycast: RayCast3D

const RAY_LENGTH = 1000

func _ready() -> void:
	_hide_ui()
	_camera = $CameraPivot/Camera3D
	_current_battle = 1
	_start_phase(GamePhase.SPAWN)

func _hide_ui():
	for child in get_children():
		if child is Control:
			child.hide()

func _start_phase(phase):
	_game_phase = phase
	if phase == GamePhase.SPAWN:
		$SpawnUI.show()
		$SpawnArea.show()
		_spawn_enemy_army()
	if phase == GamePhase.BATTLE:
		$SpawnUI.hide()
		$SpawnArea.hide()
		_n_units = {Team.BLUE: 0, Team.RED: 0}
		for unit in _units:
			_n_units[unit.get_team()] += 1
		$BattleUI.show()
		for unit in _units:
			unit.dead.connect(_on_unit_death)
			unit.activate()
		$CameraPivot.rotate_x(PI / 4)
	if phase == GamePhase.END:
		for unit in _units:
			unit.deactivate()
		$BattleUI.hide()
		$EndUI.show()
		$EndUI/Victory.hide()
		$EndUI/Defeat.hide()
		if _victor == Team.BLUE:
			$EndUI/Victory.show()
		else:
			$EndUI/Defeat.show()
		
func _on_battle_button_pressed() -> void:
	if not _unit_to_spawn:
		print("starting battle")
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

func _spawn_enemy_army():
	if _current_battle == 1:
		var army = load("res://army1.tscn").instantiate()
		for child in army.get_children():
			if child is Marine:
				army.remove_child(child)
				child.set_owner(null)
				add_child(child)
				child.set_team(Team.RED)
				child.add_to_group("red_team")
				_units.append(child)
		army.queue_free()

func _spawn_marine(location, direction, team):
	var team_group = "blue_team" if team == Team.BLUE else "red_team"
	var marine = marine_scene.instantiate()
	marine.initialize(location, direction)
	add_child(marine)
	marine.set_team(team)
	marine.add_to_group(team_group)
	_units.append(marine)
	return marine

func _on_unit_death(unit):
	_units.erase(unit)
	unit.remove_from_group("blue_team")
	unit.remove_from_group("red_team")
	var team = unit.get_team()
	_n_units[team] -= 1
	if _n_units[team] == 0:
		_victor = Team.BLUE if team == Team.RED else Team.RED
		_start_phase(GamePhase.END)

func _on_spawn_marine_button_pressed() -> void:
	if _unit_to_spawn:
		return
	var marine = _spawn_marine(Vector3(0, 0, 0), Vector3(0, 0, -1), Team.BLUE)
	_unit_to_spawn = marine

func _on_remove_button_pressed() -> void:
	if _unit_to_spawn:
		_units.erase(_unit_to_spawn)
		_unit_to_spawn.queue_free()
		_spawnable = false

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if _game_phase == GamePhase.SPAWN:
			if _spawnable: # place unit
				_unit_to_spawn = null
				_spawnable = false
			elif not _unit_to_spawn: # move unit
				var raycast = _raycast_mouse()
				raycast.set_collision_mask_value(1, false)
				raycast.set_collision_mask_value(2, true)
				raycast.force_raycast_update()
				var collider = raycast.get_collider()
				if collider is Marine:
					_unit_to_spawn = collider
				raycast.set_collision_mask_value(2, false)
				raycast.set_collision_mask_value(1, true)
