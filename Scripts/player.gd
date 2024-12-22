extends CharacterBody3D

@export_group("Camera Properties")
@export_range(0.1, 1.0, 0.01) var horizontal_mouse_sensitivity : float = 0.4
@export_range(0.1, 1.0, 0.01) var vertical_mouse_sesnsitivity : float = 0.4
@export_range(-90.0, -45.0, 0.1, "radians_as_degrees") var lower_tilt_angle : float = deg_to_rad(-75)
@export_range(45.0, 90, 0.1, "radians_as_degrees") var upper_tilt_angle : float = deg_to_rad(75)

@export_group("Player Nodes")
@export var head : Node3D
@export var animation_player : AnimationPlayer
@export var crouch_shape_cast : ShapeCast3D

var speed : float = 4.5
var jump_speed : float = 4.0
var crouch_speed : float = 3

var direction : Vector3
var mouse_input : Vector2

var is_crouching : bool = false

func _ready() -> void:
	crouch_shape_cast.add_exception(self)

func _physics_process(delta: float) -> void:
	if self.position.y < -100:
		self.position = Vector3.ZERO
	
	direction = get_direction()
	
	horizontal_movement()
	vertical_movement()
	update_camera()
	
	apply_gravity(delta)
	
	move_and_slide()

# gets how much the player wants to rotate
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input.x = deg_to_rad(-event.relative.x * \
		horizontal_mouse_sensitivity)
		mouse_input.y = deg_to_rad(-event.relative.y * \
		vertical_mouse_sesnsitivity)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		is_crouching

# handles horizontal movement
func horizontal_movement() -> void:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

# handles vertical movement
func vertical_movement() -> void:
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = jump_speed
		
		if Input.is_action_just_pressed("crouch"):
			crouching(is_crouching)

# applies gravity to the player
func apply_gravity(delta : float) -> void:
	velocity += get_gravity() * delta

# gets the direction that the player wants to move to
func get_direction() -> Vector3:
	var input_dir = Input.get_vector("strafe_left", "strafe_right",\
	"move_forward", "move_backward")
	
	return (global_transform.basis * \
	Vector3(input_dir.x, 0, input_dir.y)).normalized()

# camera rotation
func update_camera() -> void:
	# horizontal rotation
	rotate_y(mouse_input.x)
	# vertical rotation
	head.rotate_x(mouse_input.y)
	# the vertical rotation is between lower_tilt_angle and upper_tilt_angle
	head.rotation.x = clamp(head.rotation.x, lower_tilt_angle, upper_tilt_angle)
	
	# reset the mouse_input
	mouse_input = Vector2.ZERO

func crouching(state : bool):
	if crouch_shape_cast.is_colliding() == false:
		match state:
			true:
				if not animation_player.is_playing():
					animation_player.play("crouch", -1, -crouch_speed, true)
			false:
				if not animation_player.is_playing():
					animation_player.play("crouch", -1, crouch_speed)

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	is_crouching = not is_crouching
