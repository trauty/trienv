extends CharacterBody3D

@onready var main_cam = get_node("MainCamera")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var cam_rotation = Vector2(0, 0)
var mouse_sensitivity = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal menu

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return
	

func _input(event):
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE) else Input.MOUSE_MODE_VISIBLE)
		menu.emit()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_movement = event.relative * mouse_sensitivity
		cam_look(mouse_movement);
		

func cam_look(mouse_movement: Vector2):
	cam_rotation += mouse_movement
	cam_rotation.y = clamp(cam_rotation.y, deg_to_rad(-89.0), deg_to_rad(89.0))
	transform.basis = Basis()
	main_cam.transform.basis = Basis()
	
	rotate_object_local(Vector3.UP, -cam_rotation.x)
	main_cam.rotate_object_local(Vector3.RIGHT, -cam_rotation.y)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("mov_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("mov_left", "mov_right", "mov_forwards", "mov_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
