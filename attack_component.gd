class_name AttackComponent
extends Node3D


@export var damage: int
@export var cooldown: float
@export var range: float

var is_attacking: bool = false
var is_ready: bool = true


func _ready() -> void:
	$Cooldown.wait_time = cooldown
	$Range/CollisionShape3D/SphereShape3D.radius = range


func activate():
	is_attacking = true


func attack(target: Unit):
	pass
	
	
