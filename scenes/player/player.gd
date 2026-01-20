extends CharacterBody3D

@export var forward_velocity : float
@export var max_turn_rate : float

func _physics_process(delta: float) -> void:
	var joystick_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	rotation.y = rotation.y + -joystick_vector.x * max_turn_rate * delta
	rotation.z = rotation.z + joystick_vector.y * max_turn_rate * delta

	velocity = basis.x * forward_velocity
	move_and_slide()
  
