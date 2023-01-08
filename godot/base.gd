extends Node2D

var state = "play"


onready var debug = $CanvasLayer/Control/debug
onready var respawn = $respawn
onready var player = $player

onready var intro = $CanvasLayer/intro
onready var playermove = false

onready var start = $CanvasLayer/start
onready var fade = $CanvasLayer/fade/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	# DEBUG
	OS.set_current_screen(0)
	
	
	# ok normal stuff
	player.global_position = respawn.global_position
	start.visible = true
	
	

func _input(event):
	if start.visible && Input.is_action_just_pressed("ui_accept"):
		start.visible = false
		intro.usingend = false
		fade.play("fade")
		yield(fade, "animation_finished")
		intro.visible = true
		fade.play_backwards("fade")
		yield(fade, "animation_finished")
		intro.cutscene()

func respawn():
	player.global_position = respawn.global_position


func endgame():
	fade.play("fade")
	yield(fade, "animation_finished")
	intro.visible = false
	$CanvasLayer/end.visible = true
	fade.play_backwards("fade")
	yield(fade, "animation_finished")
	

func _on_building2_body_entered(body):
	player.candouble = true
	player.doubled = false



func _on_ending_body_entered(body):
	if body.is_in_group("player"):
		intro.usingend = true 
		fade.play("fade")
		yield(fade, "animation_finished")
		intro.visible = true
		fade.play_backwards("fade")
		yield(fade, "animation_finished")
	
		intro.cutscene()
