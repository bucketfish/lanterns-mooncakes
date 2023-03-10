extends KinematicBody2D


#establish scene name for saving
export var scene_id = "player"

onready var raycasts = {
	"floor":[$"raycasts/1", $"raycasts/2", $"raycasts/3"],
#	"left": [$"raycasts/4", $"raycasts/5", $"raycasts/6"],
#	"right": [$"raycasts/7", $"raycasts/8", $"raycasts/9"]
	}
	
	
var gots = []
#var pianosounds = [preload("res://audio/playersound/1.wav"), preload("res://audio/playersound/2.wav"), preload("res://audio/playersound/3.wav"), preload("res://audio/playersound/4.wav"), preload("res://audio/playersound/5.wav"), preload("res://audio/playersound/6.wav"), preload("res://audio/playersound/7.wav"), preload("res://audio/playersound/8.wav")]

var candouble = false
var doubled = false

onready var camera = $Camera2D

onready var sprite = $sprite
onready var animtree = $animtree.get("parameters/playback")
#constants and stuff / physics
export (int) var speed = 500
export (int) var gravity = 2400
export (float, 0, 1.0) var friction = 0.5
export (float, 0, 1.0) var acceleration = 0.15
export (float, 0, 1.0) var jumpheight = 300
export (float, 0, 1.0) var jumpinc = 0.64
export (float, 0, 1.0) var jgravity = 250
#setting up ground variables
var velocity = Vector2.ZERO
var curforce = jumpheight
var state = "idle"
var touching = false
onready var base = get_node("/root/base")

#onready var coyote = $coyote
var wasonfloor = true

var rng = RandomNumberGenerator.new()

onready var jumpsound = $AudioStreamPlayer
onready var jump = $jump
var prev_floor = true

func _ready():
	rng.randomize()
	$animtree.active = true
	
func get_input(delta):
	
	#if we don't want to take input, don't take input
	if base.state == "pause":
		velocity.x = 0
		velocity.y = 0
		return
	
	elif base.state == "scroll" or base.state == "listen":
		velocity.x = 0
		velocity.y = clamp(velocity.y + gravity * delta, -1000, 1000)
		return
		
		
	#settle these variables first

	var onfloor = raycast("floor")
	var leftwall = false
	var rightwall = false
	
	if state == "falling" && onfloor:
		set_state("land")
		
	if onfloor && !touching:
		touching = true
#		set_state("land")
		jumpsound.play()

#
	if !onfloor:
		touching = false
		
	#direction of player
	var dir = 0
	if Input.is_action_pressed("right"):
		dir += 1
	if Input.is_action_pressed("left"):
		dir -= 1
	
	#sideways speed, and/or friction
	if dir != 0:
		if state == "idle" || state == "land":
			set_state("walk")
		velocity.x = lerp(velocity.x, dir * speed, acceleration * delta * 70)
	else:
		if state == "walk" || state == "land":
			set_state("idle")
		
		velocity.x = lerp(velocity.x, 0, friction * delta * 70)
	if dir == -1:
		sprite.flip_h = true
	elif dir == 1:
		sprite.flip_h = false
		
	#apply gravity when finished jumping
	if Input.is_action_just_released("jump"):	
		if state == "jumping":
			velocity.y += jgravity
			set_state("falling")
			
		if onfloor:
			set_state("idle")
			doubled = false
			
	
	if Input.is_action_just_pressed("jump"):
		if (onfloor && state != "jumping") || (!doubled && candouble):
			
			set_state("jumping")
			
			jump.play()

			doubled = false
			
			curforce = jumpheight
			
			if !onfloor && !doubled && candouble:
				velocity.y = 0

				doubled = true
			
		
	if Input.is_action_pressed("jump"):
#		if onfloor:
#			set_state("jumping")
			
		if state == "jumping":
			velocity.y = clamp(velocity.y - curforce, -1000, 10000000)
			curforce *= jumpinc
		
		if velocity.y >= 0:
			set_state("falling")
			
		if onfloor && state == "falling":
			set_state("idle")
			doubled = false
		
	#reseting values when hitting floor
	if onfloor:
#		curforce = jumpheight
		doubled = false
		
	
	velocity.y = clamp(velocity.y + gravity * delta, -1000, 1000)
	
	if global_position.y > 630:
		base.respawn()
	
	
	
#	base.debug.text = state + ' ' + str(doubled) + ' ' + str(candouble)
	
func _physics_process(delta):
	if !base.playermove:
		return
		
	get_input(delta)
	var snap = Vector2.DOWN if state != "jumping" else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP )
	
	move_platform(delta, get_slide_count())
	tween_camera()
	
func move_platform(delta, cols):
	for x in cols:
		var i = get_slide_collision(x).collider
		if i.is_in_group("platform"):
			i.colpos = self.global_position.x - i.relpos.global_position.x
		
func tween_camera():
	pass
	
func raycast(area):
	for i in raycasts[area]:
		if i.is_colliding():
			return true
	return false
	
func set_state(new):
	state = new
	animtree.travel(state)
	

func pickup(item):
	if !(item in gots):
		gots.append(item)
		$Label.text = "you got some " + item + "!"
		$text.play("show")
