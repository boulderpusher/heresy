extends Unit

var _body_component: Node3D
var _health_component: HealthComponent
var _attack_component: AttackComponent


func _ready() -> void:
	_body_component = $MarineBody
	_attack_component = $AttackComponent
	_attack_component.shot.connect(on_shot)
	_health_component = $HealthComponent
	_health_component.health_depleted.connect(_enter_state.bind(State.DEAD))


func activate():
	super.activate()
	_health_component.activate()
	_attack_component.set_team(_team)
	_state = State.WALKING
	_body_component.play_animation("walk")


func set_team(team):
	var collision_layer = 2 if team == Main.Team.PLAYER else 3
	set_collision_layer_value(collision_layer, true)
	_team = team
	_body_component.set_team(team)


func _enter_state(state: State):
	_exit_state(_state)
	_state = state
	
	match _state:
		State.IDLE:
			_body_component.play_animation("idle")
		State.WALKING:
			_body_component.play_animation("walk")
		State.ATTACKING:
			_attack_component.activate()
		State.DEAD:
			_body_component.play_animation("idle") # TODO: add death animation
			die()


func _exit_state(state: State):
	match state:
		State.ATTACKING:
			_attack_component.deactivate()


func deactivate():
	_is_active = false
	_enter_state(State.IDLE)
	
	
func _process(delta: float) -> void:
	if not _is_active:
		return
	
	_enemies = get_tree().get_nodes_in_group(_enemy_group)
	_target = find_nearest(_enemies)
	_attack_component.set_target(_target)
	
	if not _target:
		_enter_state(State.IDLE)
	
	match _state:
		State.IDLE:
			pass
		State.WALKING:
			if _attack_component.is_target_in_range():
				_enter_state(State.ATTACKING)
		State.ATTACKING:
			if not _attack_component.is_target_in_range():
				_enter_state(State.WALKING)
		State.DEAD:
			pass


func _physics_process(delta: float) -> void:
	if _is_active and _state == State.WALKING:
		if _target:
			_direction = (_target.position - position).normalized()
		_speed = min(_speed + acceleration, max_speed)
		velocity = _speed * _direction
		#rotation = _direction
		if _direction != Vector3.ZERO:
			_body_component.look_at(position + _direction, Vector3.UP, true)
		move_and_slide()


func take_hit(damage):
	_health_component.take_damage(damage)
	

func on_shot():
	_body_component.play_animation("shoot")
