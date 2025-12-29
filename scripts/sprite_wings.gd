@tool
extends Node3D
@onready var avatar = get_parent().get_parent().get_parent()#.get_child(0)
#@onready var player = avatar.get_parent().get_parent()
@export_range(0.0,1.0,0.25) var open = 1.0
@export var flapping = 0.0
@export var flapping_speed = 1.0
@export var base_rot = Vector3.ZERO
@export_range(0.0,1.0,0.01) var gliding = 0.0
var animation_state = "idle"
var time = 0.0
@export var animated = true
@export var animation_speed = 1.0
@export var generic_flapping_speed = 1.0
var item_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !avatar.has_method("load_skin"):
		enable_item_mode()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var open_pos = Vector3.ZERO
@export var close_pos = Vector3.ZERO
@export var closed_rot = Vector3.ZERO
@export var open_rot = Vector3.ZERO
@onready var left_wing = $shoulder_left/wingLeft
@onready var right_wing = $shoulder_right/wingRight
func _process(delta):
	if item_mode:
		set_from_open(open)
		return
	if time > 64.0 * PI:
		time -= 64.0*PI
	#global_position = chest.global_position
	#rotation = chest.rotation * Vector3(-1.0,1.0,-1.0) + Vector3(0.0, chest.get_parent().rotation.y,0.0)
	open = avatar.falling*0.5
	flapping = avatar.walk_speed * 0.1# + avatar.falling*0.5
	animation_speed = 0.9 + (avatar.walk_speed*0.15+0.75)*0.1
	if avatar.animation_state == "fly":
		flapping = (1.0 - avatar.crouching*2.0)+((avatar.walk_speed*0.15+0.75)*0.1)
		#gliding = clamp(-player.velocity.y,0.0,4.0)*0.25* clamp((abs(player.velocity.x)+abs(player.velocity.z)),0.0,16.0)*0.0625
		#gliding = gliding*0.5 + (clamp(((abs(player.velocity.x)+abs(player.velocity.z)-abs(player.velocity.y)*2.0)),0.0,16.0)*0.0625)*0.5
		gliding = avatar.walk_speed*0.25 * (cos((avatar.head_angle.x))+1.0)*0.5
		gliding = clamp(gliding-generic_flapping_speed+1.0,0.0,1.0)
		open = 1.2
	else:
		gliding = lerp(gliding,0.0,delta)
	if animated:
		animation(delta)
	else:
		set_from_open(open)
	pass

@onready var shoulderL = $shoulder_left
@onready var shoulderR = $shoulder_right

func animation(delta):
	var con_open = open
	var con_rot = base_rot
	if con_open > 1.0:
		con_rot.z -= (1.0-con_open)*0.5
		con_open = 1.0
	time += delta * animation_speed *flapping_speed
	shoulderL.rotation = lerp(closed_rot,open_rot,flapping)
	shoulderL.rotation.z += sin(generic_flapping_speed*time*PI*3.0)*flapping*0.75*(1.0-gliding)+0.02*PI*flapping
	shoulderL.rotation.z += sin(generic_flapping_speed*time*10.0*PI)*gliding*0.01
	shoulderL.rotation.x += sin(generic_flapping_speed*time*12.0*PI)*gliding*0.01
	shoulderL.rotation.y += sin(generic_flapping_speed*time*PI*3.0+PI*0.5)*flapping*0.25*(1.0-gliding)+0.25*flapping
	shoulderL.rotation.x += sin(generic_flapping_speed*time*PI*3.0-PI*0.5)*flapping*0.25*(1.0-gliding)
	shoulderL.rotation.y += PI*(1.0-flapping)*0.25*(1.0-gliding)
	
	shoulderR.rotation = lerp(-closed_rot* Vector3(1.0,1.0,-1.0) + Vector3(0.0,PI,0.0),-open_rot* Vector3(1.0,1.0,-1.0) + Vector3(0.0,PI,0.0),flapping)#-closed_rot* Vector3(1.0,1.0,-1.0) + Vector3(0.0,PI,0.0)
	shoulderR.rotation.z += sin(generic_flapping_speed*time*PI*3.0)*flapping*0.75*(1.0-gliding)+0.02*PI*flapping
	shoulderR.rotation.z += sin(generic_flapping_speed*time*10.0*PI)*gliding*0.01
	shoulderR.rotation.x += sin(generic_flapping_speed*time*12.0*PI)*gliding*0.01
	shoulderR.rotation.y -= sin(generic_flapping_speed*time*PI*3.0+PI*0.5)*flapping*0.25*(1.0-gliding)+0.25*flapping
	shoulderR.rotation.x -= sin(generic_flapping_speed*time*PI*3.0-PI*0.5)*flapping*0.25*(1.0-gliding)
	shoulderR.rotation.y -= PI*(1.0-flapping)*0.25*(1.0-gliding)
	
	con_open = (sin(generic_flapping_speed*time*PI*3.0-PI*0.5)+1.0)*0.5*flapping+0.1*flapping+gliding
	
	
	set_from_open(con_open)
	pass

func set_from_open(val = open):
	val = clamp(val,0.0,1.0)
	left_wing.position.x = remap(float(int(val*3.0)*0.333),1.0,0.0,open_pos.x,close_pos.x)
	left_wing.position.y = remap(float(int(val*3.0)*0.333),1.0,0.0,open_pos.y,close_pos.y)
	left_wing.position.z = remap(float(int(val)),1.0,0.0,open_pos.z,close_pos.z)
	left_wing.frame = (3-int(val*3.0))
	right_wing.position.x = remap(float(int(val*3.0)*0.333),1.0,0.0,open_pos.x,close_pos.x)
	right_wing.position.y = remap(float(int(val*3.0)*0.333),1.0,0.0,open_pos.y,close_pos.y)
	right_wing.position.z = remap(float(int(val)),1.0,0.0,open_pos.z,close_pos.z)
	right_wing.frame = (3-int(val*3.0))
	
	pass


func enable_item_mode():
	item_mode = true
	pass

func set_enchanted_col(col) -> void:
	var mat = $shoulder_left/wingLeft.material_override.duplicate()
	mat.set("shader_parameter/enchanted_col",col)
	$shoulder_left/wingLeft.material_override = mat
	$shoulder_right/wingRight.material_override = mat
	pass
