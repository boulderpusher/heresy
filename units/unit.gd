class_name Unit
extends CharacterBody3D


signal died

enum State {IDLE, WALKING, ATTACKING, DEAD}

@export var max_speed: float
@export var acceleration: float

var body_component: CharacterBody3D
var health_component: HealthComponent
var attack_component: AttackComponent

var state: State = State.IDLE
var is_active: bool = false
var speed: float = 0
var direction: Vector3 = Vector3.ZERO

var team: Main.Team
var target: Unit = null
var enemies: Array[Node]


func _ready() -> void:
	body_component = $BodyComponent
	attack_component = $AttackComponent
	health_component = $HealthComponent
	health_component.health_depleted.connect(die)


func initialize(team):
	self.team = team
	body_component.set_team(team)


func _process(delta: float) -> void:
	enemies = get_tree().get_nodes_in_group("enemy_army")
	if is_active:
		if state == State.IDLE:
			pass
		elif state == State.DEAD:
			pass
		elif state == State.WALKING:
			target = find_nearest(enemies)
			if not target:
				state == State.IDLE
			else:
				attack_component.set_target(target)
				if attack_component.is_target_in_range():
					attack_component.activate()
					state == State.ATTACKING
		elif state == State.ATTACKING:
			if not target:
				target = find_nearest(enemies)
			if target:
				attack_component.set_target(target)
				if not attack_component.is_target_in_range():
					attack_component.deactivate()
					state = State.WALKING


func _physics_process(delta: float) -> void:
	if is_active and state == State.WALKING:
		if target:
			direction = (target.position - position).normalized()
		speed = min(speed + acceleration, max_speed)
		velocity = speed * direction
		if direction != Vector3.ZERO:
			look_at(direction, Vector3.UP, true)
		move_and_slide()


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
	is_active = true


func deactivate():
	is_active = false


func take_hit(damage):
	health_component.take_damage(damage)


func die():
	state = State.DEAD
	died.emit()
