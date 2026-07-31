extends Node

enum Team {PLAYER, ENEMY}
var marine_scene = load("res://units/marine/marine.tscn")


func _ready() -> void:
	var marine = marine_scene.instantiate()
	marine.position = Vector3(1, 0, 0)
	add_child(marine)
	marine.initialize(Team.PLAYER)


func _process(delta: float) -> void:
	pass
