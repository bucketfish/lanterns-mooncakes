extends Node2D

var state = "play"


onready var debug = $debug
onready var respawn = $respawn
# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_current_screen(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_death_body_entered(body):
	if body.is_in_group("player"):
		body.global_position = respawn.global_position
