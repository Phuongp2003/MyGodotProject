extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -750.0
const maxDJumpTurn = 1
@onready var sprite_2d = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isLeft = false
var jumpDTurn = 1

func _physics_process(delta):
	print_debug(jumpDTurn)
	print_debug(is_on_wall())
	# Default move action
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
		
	## Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	## Handle double jump
	if Input.is_action_just_pressed("jump") and jumpDTurn > 0:
		jumpDTurn -= 1
		velocity.y = JUMP_VELOCITY * (8.0 / 10.0)

	# On-floor actions
	if is_on_floor():
		jumpDTurn = maxDJumpTurn
		if velocity.x != 0:
			sprite_2d.animation = "run"
		else:
			sprite_2d.animation = "default"

	# On-air actions
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 0:
			if jumpDTurn == maxDJumpTurn:
				sprite_2d.animation = "jump"
			else:
				sprite_2d.animation = "double_jump"
		else:
			sprite_2d.animation = "fall"
	
	# On-wall action
	if is_on_wall() and Input.is_action_pressed("hold_wall"):
		velocity.y = 0
		if velocity.y != 0:
			sprite_2d.animation = "wall_jump"
		else:
			sprite_2d.animation = "wall_wait"

		var wallDirection = Input.get_axis("move_up", "move_down")
		if wallDirection: velocity.y = wallDirection * (SPEED / 2)
		else: velocity.y = move_toward(velocity.y, 0, SPEED / 2)

	move_and_slide()

	# Sprite2D flip by move
	if velocity.x < 0: isLeft = true
	if velocity.x > 0: isLeft = false
	sprite_2d.flip_h = isLeft;
