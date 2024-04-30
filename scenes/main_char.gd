extends CharacterBody2D

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

@onready var boss_room_1 = $"../BossRoom1"
@onready var boss_room_2 = $"../BossRoom2"
@onready var tile_map = $"../TileMap"

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
			# Reset dash variables and make player visible again
			isDashing = false
			dashTimer = 0.0
			velocity.x = 0
			sprite_2d.set_physics_process(true)
		return
		
	# Default move action
	var direction = Input.get_axis("left", "right")
	if direction:
		if Input.is_action_pressed("hold_wall-run"):
			velocity.x = direction * SPEED * 1.3
		else:
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
		if Input.is_action_just_pressed("hold_wall-run"):
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

	#active event
	## Boss room 1 active
	if boss_active():
		boss_room_1.activate_boss_room()
	## Boss room 2 active
	if boss2_active():
		boss_room_2.activate_boss_room()
	## Deactive all boss room
	if Input.is_action_just_pressed("dev_deactive_boss"):
		boss_room_1.deactivate_boss_room()
		boss_room_2.deactivate_boss_room()
		
func boss_active() -> bool:
	var pos = Rect2(boss_room_activation.x - 32, boss_room_activation.y - 32, 64, 64)
	return pos.has_point(position)
	
func boss2_active() -> bool:
	var pos = Rect2(boss_room_activation_2.x - 32, boss_room_activation_2.y - 32, 64, 64)
	return pos.has_point(position)
func dash():
	if not isDashing:
		isDashing = true
		dashTimer = 0.0
		# Move the player a short distance horizontally
		if isLeft:
			velocity.x = -DASH_DISTANCE / DASH_DURATION
		else:
			velocity.x = DASH_DISTANCE / DASH_DURATION
