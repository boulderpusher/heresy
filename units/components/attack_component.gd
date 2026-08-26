class_name AttackComponent
extends Node3D

signal shot

@export var damage: int
@export var cooldown: float
@export var attack_range: float

var is_active: bool = false
var is_ready: bool = true
var cooldown_timer: Timer
var target: Unit
var _team: Main.Team

func _ready() -> void:
	cooldown_timer = $CooldownTimer
	cooldown_timer.wait_time = cooldown
	$AttackRange/CollisionShape3D.shape.radius = attack_range


func set_team(team):
	_team = team
	if team == Main.Team.PLAYER:
		$AttackRange.set_collision_mask_value(3, true)
	else:
		$AttackRange.set_collision_mask_value(2, true)


func _process(delta: float) -> void:
	if is_active and is_ready:
		attack()
		shot.emit()


func activate():
	is_active = true
	

func deactivate():
	is_active = false


func set_target(new_target: Unit):
	target = new_target


func is_target_in_range():
	return target in $AttackRange.get_overlapping_bodies()


func attack():
	if target and is_target_in_range():
		target.take_hit(damage)
	cooldown_timer.start()
	is_ready = false


func _on_cooldown_timer_timeout() -> void:
	is_ready = true
