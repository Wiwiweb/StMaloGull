extends CharacterBody3D

enum State {
	IDLE,
	STUNNED,
}

@onready var stun_timer: Timer = $StunTimer
@onready var animation_player: AnimationPlayer = $Seagull_model/AnimationPlayer

@export var invert_y_axis: bool = false

@export var forward_velocity: float = 15
@export var stunned_back_velocity: float = 5
@export var max_turn_rate: float = 1.2
@export var max_tilt_when_turning: float = 0.4
@export var tilt_speed_when_turning: float = 2
@export var tilt_speed_multiplier_when_returning: float = 5.0

var state: State = State.IDLE

func _physics_process(delta: float) -> void:
	var motion := Vector3.ZERO
	if state == State.IDLE:
		var joystick_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
		if invert_y_axis:
			joystick_vector.y = -joystick_vector.y
		rotation.y = rotation.y + -joystick_vector.x * max_turn_rate * delta
		rotation.z = rotation.z + joystick_vector.y * max_turn_rate * delta
		var target_rotation_x := joystick_vector.x * max_tilt_when_turning
		var turning_deeper: bool = abs(target_rotation_x) > abs(rotation.x)
		var tilt_speed_multiplier := 1.0
		if not turning_deeper:
			tilt_speed_multiplier = tilt_speed_multiplier_when_returning
		rotation.x = lerpf(rotation.x, target_rotation_x, delta * tilt_speed_when_turning * tilt_speed_multiplier)

		motion = basis.x * forward_velocity * delta
	elif state == State.STUNNED:
		motion = basis.x * -stunned_back_velocity * stun_timer.time_left / stun_timer.wait_time * delta

	var collision := move_and_collide(motion)
	if collision:
		get_stunned()
  
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		get_stunned()

func get_stunned() -> void:
	print("Stunned!")
	state = State.STUNNED
	animation_player.pause()
	stun_timer.start()


func _on_stun_timer_timeout() -> void:
	print("Recovered from stun")
	animation_player.play()
	state = State.IDLE
