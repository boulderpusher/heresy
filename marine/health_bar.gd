extends ProgressBar

var _parent: Node3D
var _camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parent = get_parent()
	_camera = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = _camera.unproject_position(_parent.global_position) + Vector2(-size.x/2, 0) + Vector2(0, -20)
	visible = not _camera.is_position_behind(_parent.position)
