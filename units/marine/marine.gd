extends Unit

var _body_component: Node3D
var _health_component: HealthComponent
var _attack_component: AttackComponent


func _ready() -> void:
	_body_component = $MarineBody
	_attack_component = $AttackComponent
	_attack_component.shot.connect(on_shot)
	_health_component = $HealthComponent
	_health_component.health_depleted.connect(die)


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


func _process(delta: float) -> void:
	if not _is_active:
		return
	_enemies = get_tree().get_nodes_in_group(_enemy_group)
	if _state == State.IDLE:
		pass
	elif _state == State.DEAD:
		pass
	elif _state == State.WALKING:
		_target = find_nearest(_enemies)
		if not _target:
			_state == State.IDLE
			_body_component.play_animation("idle")
		else:
			_attack_component.set_target(_target)
			if _attack_component.is_target_in_range():
				_attack_component.activate()
				_state = State.ATTACKING
	elif _state == State.ATTACKING:
		if not _target:
			_target = find_nearest(_enemies)
		if _target:
			_attack_component.set_target(_target)
			if not _attack_component.is_target_in_range():
				_attack_component.deactivate()
				_state = State.WALKING
				_body_component.play_animation("walk")


func _physics_process(delta: float) -> void:
	if _is_active and _state == State.WALKING:
		if _target:
			_direction = (_target.position - position).normalized()
		_speed = min(_speed + acceleration, max_speed)
		velocity = _speed * _direction
		#rotation = _direction
		if _direction != Vector3.ZERO:
			_body_component.look_at(_direction, Vector3.UP, true)
		move_and_slide()


func take_hit(damage):
	_health_component.take_damage(damage)
	

func on_shot():
	_body_component.play_animation("shoot")
