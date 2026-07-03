extends CharacterBody3D

@export var speed = 10

var animation_player

func _ready():
	animation_player = get_node("Pivot/Body/AnimationPlayer")
	animation_player.play("walk")

func _physics_process(_delta):
	var direction = Vector3.BACK
	velocity = direction * speed
	$Pivot.basis = Basis.looking_at(direction, Vector3.UP, true)
	move_and_slide()

func _on_timer_timeout() -> void:
	speed = 0
	animation_player.play("shoot")
