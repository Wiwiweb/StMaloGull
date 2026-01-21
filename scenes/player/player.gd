extends CharacterBody3D

enum State {
	IDLE,
	STUNNED,
}

@onready var stun_timer : Timer = $StunTimer

@export var forward_velocity : float
@export var stunned_back_velocity : float
@export var max_turn_rate : float

var state : State = State.IDLE

func _physics_process(delta: float) -> void:
	var motion := Vector3.ZERO
	if state == State.IDLE:
		var joystick_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
		rotation.y = rotation.y + -joystick_vector.x * max_turn_rate * delta
		rotation.z = rotation.z + joystick_vector.y * max_turn_rate * delta

		motion = basis.x * forward_velocity * delta
	elif state == State.STUNNED:
		motion = basis.x * -stunned_back_velocity * stun_timer.time_left/stun_timer.wait_time * delta

	var collision := move_and_collide(motion)
	if collision:
		get_stunned()
  
func get_stunned() -> void:
	print("Stunned!")
	state = State.STUNNED
	stun_timer.start()


func _on_stun_timer_timeout() -> void:
	print("Recovered from stun")
	state = State.IDLE
