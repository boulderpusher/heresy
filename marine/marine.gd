extends CharacterBody3D
class_name Marine

signal dead

@export var speed: float  = 10.0
@export var max_health: int = 100
@export var attack_damage: int = 10

var _team: Main.Team
var _enemy_group
var _armor_material: Material
var _eyes_material: Material
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D
var _health_bar: ProgressBar

var _current_health: int
var _direction: Vector3
var _speed: float

enum State {IDLE, WALKING, ATTACKING}

var _state = State.IDLE
var _target: Node3D
var _can_attack: bool = true
var _is_active: bool = false

func _ready():
	_skeleton = get_node("Pivot/Body/Armature/Skeleton3D")
	_animation_player = get_node("Pivot/Body/AnimationPlayer")
	_health_bar = get_node("HealthBar")
	_health_bar.max_value = max_health
	_current_health = max_health
	_health_bar.value = _current_health
	_health_bar.hide()

func _process(delta):
	if _state == State.ATTACKING: # state machine deez nuts
		if not _target:
			_select_new_target()
		_attack()
	elif _state == State.WALKING:
		_select_new_target()
		_walk()
	elif _state == State.IDLE:
		_idle()
			
func _physics_process(_delta):
	if _is_active:
		velocity = _direction.normalized() * _speed
		move_and_slide()

func initialize(initial_position, initial_direction):
	position = initial_position
	_direction = initial_direction

func activate():
	_is_active = true
	_health_bar.show()
	_select_new_target()

func deactivate():
	_is_active = false
	_health_bar.hide()
	_set_state(State.IDLE)

func _attack():
	if not _target:
		return
	_direction = _target.position - position
	_look_at(_direction)
	if _can_attack:
		_animation_player.play("shoot")
		_target.take_damage(attack_damage)
		_can_attack = false
		$AttackCooldown.start()
		
func take_damage(damage):
	_current_health = max(0, _current_health - damage)
	_health_bar.value = _current_health
	if _current_health == 0:
		die()
		
func die():
	dead.emit(self)
	queue_free()
	
func _walk():
	if not _target:
		return
	_direction = _target.position - position
	_look_at(_direction)

func _idle():
	pass

func _look_at(direction):
	if direction != Vector3.ZERO and direction != Vector3.UP:
		$Pivot.basis = Basis.looking_at(direction, Vector3.UP, true)

func _set_state(new_state: State):
	_state = new_state
	if _state == State.WALKING:
		_speed = speed
		_animation_player.play("walk")
	elif _state == State.ATTACKING:
		_speed = 0
		_animation_player.play("shoot")
	elif _state == State.IDLE:
		_speed = 0
		_animation_player.play("idle")

func _select_new_target():
	var enemies = $AttackRange.get_overlapping_bodies()
	if not enemies:
		enemies = get_tree().get_nodes_in_group(_enemy_group)
		_target = _get_nearest(enemies)
		if  _target:
			_set_state(State.WALKING)
		else:
			_set_state(State.IDLE)
	else:
		_target = _get_nearest(enemies)
		_set_state(State.ATTACKING)
		
func _get_nearest(bodies):
	var min_distance = INF 
	var nearest = null
	for body in bodies:
		var distance = position.distance_to(body.position)
		if distance < min_distance:
			min_distance = min_distance
			nearest = body
	return nearest

# store team and change armor color
func set_team(team: Main.Team):
	if team == Main.Team.BLUE:
		_team = Main.Team.BLUE
		_enemy_group = "red_team"
		_armor_material = load("res://marine/materials/armor_blue.tres")
		_eyes_material = load("res://marine/materials/eyes_red.tres")
		set_collision_layer_value(2, true)
		$AttackRange.set_collision_mask_value(3, true)

	if team == Main.Team.RED:
		_team = Main.Team.RED
		_enemy_group = "blue_team"
		_armor_material = load("res://marine/materials/armor_red.tres")
		_eyes_material = load("res://marine/materials/eyes_green.tres")
		set_collision_layer_value(3, true)
		$AttackRange.set_collision_mask_value(2, true)

	for bone in _skeleton.get_children():
		if bone is not BoneAttachment3D:
			continue
		for mesh_instance in bone.get_children():
			if mesh_instance is not MeshInstance3D:
				continue
			var mesh: Mesh = mesh_instance.mesh
			for surf_idx in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(surf_idx)
				if material.resource_name == "armor_base":
					mesh_instance.set_surface_override_material(surf_idx, _armor_material)
				if material.resource_name == "eyes_base":
					mesh_instance.set_surface_override_material(surf_idx, _eyes_material)

func get_team():
	return _team

func _on_attack_cooldown_timeout() -> void:
	_can_attack = true

func _on_attack_range_body_entered(body: Node3D) -> void:
	if _is_active:
		if _state != State.ATTACKING:
			_set_state(State.ATTACKING)
			_target = body
