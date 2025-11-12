extends CharacterBody3D

@export var forward_velocity : float = 5.0

func _physics_process(_delta: float) -> void:
	velocity.z = -forward_velocity
	move_and_slide()
  
