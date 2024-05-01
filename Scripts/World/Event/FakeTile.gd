extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(true)
	set_physics_process(true)
	set_layer_enabled(0, true)

# Function to activate
func activate():
	set_visible(true)
	set_physics_process(true)
	set_layer_enabled(0, true)

# Function to deactivate
func deactivate():
	set_visible(false)
	set_physics_process(false)
	set_layer_enabled(0, false)
