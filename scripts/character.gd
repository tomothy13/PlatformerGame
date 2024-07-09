extends CharacterBody2D

const GROUND_FRICTION = 55
const AIR_FRICTION = 80
const ACCEL = 50
const SPEED = 175.0
const JUMP_VELOCITY = -225.0
const DASH_ACCEL = 400
const DASH_SPEED = 10000
const DASH_AIR_MULT = 1.3

var jumped = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var gravity_timer = 1

var jump_buffer = 0

func _physics_process(delta):
	
	# jump buffering system, sets a value for how many more frames a jump buffer input is active for
	# i want pressing jump to buffer a jump to be more powerful and forgiving than holding the jump key
	if Input.is_action_just_pressed("jump"): 
		jump_buffer = 5
	elif Input.is_action_pressed("jump"):
		jump_buffer = 3
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement acceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, SPEED*direction, ACCEL)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION)
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION)

	# dash & dash jump tech
	# if a player dashes, it should freeze their horizontal movement and prevent gravity from taking effect dashing
	# if a player presses the dash key and has a jump buffered/presses jump, it will increase their dash distances by the DASH_AIR_MULT
	# you cannot dash on the ground, you can only dash while in the air. the code checks if the player has jumped recently
	if Input.is_action_just_pressed("dash") and Input.is_action_just_pressed("jump") and not is_on_floor():
		velocity.y = 0
		gravity_timer = -1
		if direction and not jumped:
			velocity.x = move_toward(velocity.x, direction*DASH_SPEED, DASH_ACCEL*DASH_AIR_MULT)
		elif not jumped:
			velocity.x = move_toward(velocity.x, DASH_SPEED, DASH_ACCEL*DASH_AIR_MULT)
		jumped = true
	elif Input.is_action_just_pressed("dash") and not is_on_floor():
		velocity.y = 0
		gravity_timer = 0
		if direction and not jumped:
			velocity.x = move_toward(velocity.x, direction*DASH_SPEED, DASH_ACCEL)
		elif not jumped:
			velocity.x = move_toward(velocity.x, DASH_SPEED, DASH_ACCEL)
		jumped = true
		
	# Add the gravity.
	# Checks if the gravity timer is less than 1 to decide if gravity should be applied based on how recently a dash was input
	if not is_on_floor():
		if gravity_timer < 1:
			gravity_timer +=1
		else: 
			velocity.x += gravity * delta
	# this resets the jumped variable once the player has touched the ground
	else:
		jumped = false
		
	#gravity_modifier = 1
	
	move_and_slide()
