extends Node2D
@onready var trigger = $Trigger
@onready var tile = $Tile
@onready var trigger_area = $Trigger/TriggerArea
@onready var fake_tile = $FakeTile
@onready var player = $"../Player"


var playerInArea = false
var print = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("dev_deactive_boss"):
		tile.deactivate_boss_room()
		playerInArea = false
	if playerInArea:
		tile.activate_boss_room()
		fake_tile.deactivate()
		
func _on_trigger_body_entered(body):
	if body.has_method("player"):
		playerInArea = true
