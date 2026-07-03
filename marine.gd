extends CharacterBody3D

@export var speed = 10

func _physics_process(_delta):
	var animation_player = get_node("Pivot/Body/AnimationPlayer")
	animation_player.play("walk")
	var direction = Vector3.BACK
	velocity = direction * speed
	$Pivot.basis = Basis.looking_at(direction, Vector3.UP, true)
	move_and_slide()
