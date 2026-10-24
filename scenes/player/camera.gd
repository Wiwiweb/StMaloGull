extends Node3D

@export var max_camera_rotation: float = 0.15
@export var camera_lerp_speed: float = 5.0

func _process(delta: float) -> void:
    var joystick_vector := Input.get_vector("move_left", "move_right", "move_down", "move_up")
    var target_rotation_y := joystick_vector.x * max_camera_rotation
    var target_rotation_z := joystick_vector.y * max_camera_rotation
    var target_rotation := Vector3(0, target_rotation_y, target_rotation_z)
    var lerp_weight := 1 - exp(-camera_lerp_speed * delta) # https://www.youtube.com/watch?v=LSNQuFEDOyQ
    rotation = rotation.lerp(target_rotation, lerp_weight)
