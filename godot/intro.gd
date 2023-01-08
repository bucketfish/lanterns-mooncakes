extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal next
onready var label = $text
onready var anim = $anim
onready var tween = $Tween
onready var overlay = $overlay
onready var base = get_node("/root/base")

export var usingend = false

var actions = [
	"hey, it's the mid-autumn festival! i heard the harvest is pretty good this year.",
	"look, they're all celebrating with lanterns and mooncakes!",
	"man, wish we could have a mooncake.....",
	"surely they won't mind if we take a little bit of ingredients, right?",
	"next_scene",
	"here's the plan!",
	"we start at our hut...",
	"next_point",
	"travel to the next one, grab some flour...",
	"next_point",
	"and then we need some eggs!",
	"next_point",
	"and finally some sugar.",
	"next_point",
	"make your way back here carefully!",
	"use the lanterns to your advantage. they can swing really far.",
	"i believe in you!"
]

var end = [
	"hey, you did it! congrats!",
	"now we can enjoy a mooncake and celebrate the harvest, too.",
	"yum..."
]

var textcount = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func cutscene():
	base.playermove = false
	
	var scene = 1
	var point = 0
	
	var the = actions
	
	if usingend:
		the = end
		anim.play("end")
	else:
		$Sprite.visible = true
		
	for i in range(0, the.size()):
		if the[i] == "next_scene":
			scene += 1
			anim.play(str(scene))
		elif the[i] == "next_point":
			if point == 0:
				overlay.visible = true
				overlay.frame = 4 + point
			else:
				overlay.frame = 4 + point
			point += 1
		else:
			
			label.text = the[i]
			tween.interpolate_property(label, "percent_visible", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
			yield(self, "next")
	
	if usingend:
		base.endgame()
		
	else:
		base.fade.play("fade")
		yield(base.fade, "animation_finished")
		self.visible = false
		base.fade.play_backwards("fade")
		yield(base.fade, "animation_finished")
		base.playermove = true

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("next")
	
