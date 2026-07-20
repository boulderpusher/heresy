extends Node

enum Team {PLAYER, ENEMY}
var marine_scene = load("res://units/marine/marine.tscn")


func _ready() -> void:
	var marine = marine_scene.instantiate()
	marine.initialize(Team.PLAYER)
	marine.position = Vector3(0, 0, 0)


func _process(delta: float) -> void:
	pass
