extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)
	set_physics_process(false)
	set_layer_enabled(0, false)

# Function to activate the BossRoom
func activate_boss_room():
	set_visible(true)
	set_physics_process(true)
	set_layer_enabled(0, true)

# Function to deactivate the BossRoom
func deactivate_boss_room():
	set_visible(false)
	set_physics_process(false)
	set_layer_enabled(0, false)
