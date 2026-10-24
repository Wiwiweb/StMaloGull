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

@export var bank_angle_max: float = deg_to_rad(25)
@export var bank_speed_when_turning: float = 2.5

@export var pitch_angle_slowdown: float = deg_to_rad(60)
@export var pitch_angle_max: float = deg_to_rad(80)

var state: State = State.IDLE
var bank_velocity: float = 0.0

func _physics_process(delta: float) -> void:
	var motion := Vector3.ZERO
	if state == State.IDLE:
		var joystick_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
		
		# Turn
		rotation.y = rotation.y + -joystick_vector.x * max_turn_rate * delta

		# Pitch
		if invert_y_axis:
			joystick_vector.y = -joystick_vector.y
		var pitch_slowdown_factor := 1.0
		var pitching_deeper: bool = sign(joystick_vector.y) == sign(rotation.z)
		if pitching_deeper and abs(rotation.z) > pitch_angle_slowdown:
			pitch_slowdown_factor = 1.0 - (abs(rotation.z) - pitch_angle_slowdown) / (pitch_angle_max - pitch_angle_slowdown)
		rotation.z = rotation.z + joystick_vector.y * max_turn_rate * pitch_slowdown_factor * delta

		# Slight and smooth bank while turning
		var target_rotation_x := joystick_vector.x * bank_angle_max
		# Critically damped spring: bank accelerates toward its target (ease-in) and settles smoothly (ease-out)
		var bank_acceleration := bank_speed_when_turning * bank_speed_when_turning * (target_rotation_x - rotation.x) - 2.0 * bank_speed_when_turning * bank_velocity
		bank_velocity += bank_acceleration * delta
		rotation.x += bank_velocity * delta

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
