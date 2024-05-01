extends CharacterBody2D

class_name Player

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const maxDJumpTurn = 1
const boss_room_activation = Vector2(27 * 16, 40 * 16)
const boss_room_activation_2 = Vector2(51 * 16, 11 * 16)
const DASH_DISTANCE = 75
const DASH_DURATION = 0.3
const DASH_DELAY = 0.5

@onready var sprite_2d = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isLeft = false
var jumpDTurn = 1
var isDashing = false
var dashTimer = 0.0

# Varialble will save for player
var isBoss1Meet = false
var isBoss1Clear = false
var isBoss2Meet = false
var isBoss2Clear = false

func _physics_process(delta):
	if isDashing:
		dashTimer += delta
		if dashTimer <= DASH_DELAY:
			# Player disappears during dash delay
			if dashTimer >= 0.25:
				sprite_2d.visible = false
			if dashTimer >= DASH_DURATION:
				sprite_2d.visible = true
				sprite_2d.animation = "appear"
			if dashTimer <= DASH_DURATION:
				# Player moves during the dash duration
				move_and_slide()
			sprite_2d.set_physics_process(false)
		else:
			# Reset dash variables
			isDashing = false
			dashTimer = 0.0
			velocity.x = 0
			sprite_2d.set_physics_process(true)
		return
		
	# Default move action
	var direction = Input.get_axis("left", "right")
	if direction:
		## Run / walk check
		if Input.is_action_pressed("hold_wall-run", true):
			velocity.x = direction * SPEED * 1.5
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
		
	## Handle jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		## Handle double jump
		elif jumpDTurn > 0:
			jumpDTurn -= 1
			velocity.y = JUMP_VELOCITY

	# On-floor actions
	if is_on_floor():
		jumpDTurn = maxDJumpTurn
		if velocity.x != 0:
			sprite_2d.animation = "run"
		else:
			sprite_2d.animation = "default"
		if Input.is_action_just_pressed("hold_wall-run", true):
			dash()
			sprite_2d.animation = "disappear"

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
	if is_on_wall() and Input.is_action_pressed("hold_wall-run"):
		jumpDTurn = maxDJumpTurn
		velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			if (is_on_wall()):
				if isLeft:
					velocity.x = SPEED * 3
				else:
					velocity.x = -SPEED * 3
			elif jumpDTurn > 0:
				jumpDTurn -= 1
				velocity.y = JUMP_VELOCITY
				
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
		
func dash():
	if not isDashing:
		isDashing = true
		dashTimer = 0.0
		# Move the player a short distance horizontally
		if isLeft:
			velocity.x = -DASH_DISTANCE / DASH_DURATION
		else:
			velocity.x = DASH_DISTANCE / DASH_DURATION
			
func player():
	pass
