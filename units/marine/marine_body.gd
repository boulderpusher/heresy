extends CharacterBody3D

var _skeleton
var _armor_material: Material
var _eyes_material: Material


func _ready():
	_skeleton = $Armature/Skeleton3D


# store team and change armor color
func set_team(team: Main.Team):
	if team == Main.Team.PLAYER:
		_armor_material = load("res://units/marine/materials/armor_blue.tres")
		_eyes_material = load("res://units/marine/materials/eyes_red.tres")
	else:
		_armor_material = load("res://units/marine/materials/armor_red.tres")
		_eyes_material = load("res://units/marine/materials/eyes_green.tres")
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
