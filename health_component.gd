class_name HealthComponent
extends ProgressBar

signal dead

@export var max_health: int
var current_health: int
var parent: Node3D
var camera: Camera3D


func _ready() -> void:
	parent = get_parent()
	camera = get_viewport().get_camera_3d()
	
	max_value = max_health
	current_health = max_health
	value = current_health


func _process(delta: float) -> void:
	position = camera.unproject_position(parent.global_position) + Vector2(-size.x/2, 0) + Vector2(0, -20)
	#if _camera.is_position_behind(_parent.position):
	#	visible = false


func take_damage(damage: int):
	if current_health > 0:
		current_health = max(0, current_health - damage)
		value = current_health
		if current_health == 0:
			dead.emit()
			
			
