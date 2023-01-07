extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0, 0)
var colpos = 0
onready var tween = $Tween
onready var relpos = $CollisionShape2D2/Position2D
var prevpos = 0

const turnfactor = 0.6
const speed = 40
const returnspeed = 0.2

onready var base = get_node("/root/base")
# Called when the node enters the scene tree for the first time.
func _ready():
#	defaultpos = position
	pass
	


func _physics_process(delta):

	var newpos = turnfactor * colpos
	
	if newpos == prevpos:
		newpos = 0
		tween.interpolate_property(self, "rotation_degrees",
			self.rotation_degrees, newpos, returnspeed,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	else:
		tween.interpolate_property(self, "rotation_degrees",
			self.rotation_degrees, newpos, abs((newpos - self.rotation_degrees) / speed),
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
	prevpos = newpos
	
#	move_and_collide(Vector2())
	
	colpos = 0
	
	

