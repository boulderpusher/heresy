class_name Unit
extends CharacterBody3D


signal died

enum State {IDLE, WALKING, ATTACKING, DEAD}

@export var max_speed: float
@export var acceleration: float

var _state: State = State.IDLE
var _is_active: bool = false
var _speed: float = 0
var _direction: Vector3 = Vector3.ZERO

var _team: Main.Team
var _target: Unit = null
var _enemies: Array[Node]


func find_nearest(bodies):
	var min_distance = INF 
	var nearest = null
	for body in bodies:
		var distance = position.distance_to(body.position)
		if distance < min_distance:
			min_distance = min_distance
			nearest = body
	return nearest


func activate():
	_is_active = true


func deactivate():
	_is_active = false


func get_team():
	return _team


func die():
	_state = State.DEAD
	died.emit()
