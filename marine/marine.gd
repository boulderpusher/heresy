extends CharacterBody3D
class_name Marine

@export var speed = 10

var _team: Main.Team
var _armor_material: Material
var _eyes_material: Material
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D

var _direction: Vector3
var _speed

func _ready():
	_skeleton = get_node("Pivot/Body/Armature/Skeleton3D")
	_animation_player = get_node("Pivot/Body/AnimationPlayer")
	_animation_player.play("walk")
	_direction = Vector3.FORWARD

func _physics_process(_delta):
	velocity = _direction * speed
	$Pivot.basis = Basis.looking_at(_direction, Vector3.UP, true)
	move_and_slide()

func shoot():
	_speed = 0
	_animation_player.play("shoot")
	
func walk(direction):
	_speed = speed
	_direction = direction
	_animation_player.play("walk")

func set_team(team: Main.Team):
	if team == Main.Team.BLUE:
		_team = Main.Team.BLUE
		_armor_material = load("res://marine/materials/armor_blue.tres")
		_eyes_material = load("res://marine/materials/eyes_red.tres")
	if team == Main.Team.RED:
		_team = Main.Team.RED 
		_armor_material = load("res://marine/materials/armor_red.tres")
		_eyes_material = load("res://marine/materials/eyes_green.tres")
		
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
