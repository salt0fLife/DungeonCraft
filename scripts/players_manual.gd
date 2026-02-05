@tool
extends Node3D

@export var desired_open:float = 0.0
@export var desired_center_page_flip:float = 0.0
@export var flip_dir:int = 0
var page_flip:float = 0.0
var center_page_flip:float = 0.0
var open:float = 0.0

var page_number:int = 2 #so you can flip back on start and it looks nice
# Called when the node enters the scene tree for the first time.
func _ready():
	desired_open = 0.9 #makes it open cool
	load_page_backward()
	pass # Replace with function body.

@onready var cover_1 = $cover1
@onready var cover_2 = $cover2
@onready var center_page = $centerPage
func _process(delta):
	cover_1.rotation.z = PI*0.5 - open*PI*0.5
	cover_2.rotation.z = PI*0.5 + open*PI*0.5
	center_page.rotation.z = lerp(cover_2.rotation.z,cover_1.rotation.z,center_page_flip)
	center_page.position.x = 0.02*open * (-1.0+center_page_flip*2.0)
	center_page.position.y = 0.025* (open)
	
	center_page_flip = lerp(center_page_flip,desired_center_page_flip,delta*8.0)
	open = lerp(open,desired_open,delta*4.0)
	
	##for debug in editor
	if flip_dir > 0:
		flip_dir = 0
		flip_forward()
	elif flip_dir < 0:
		flip_dir = 0
		flip_back()
	pass

func flip_forward() -> void:
	page_number += 2
	if page_number > contents.size()+1:
		page_number -= 2
		#end of book
		return
	desired_center_page_flip = 0.0
	center_page_flip = 1.0
	load_page_forward()
	pass

func flip_back() -> void:
	page_number -= 2
	if page_number < 0:
		page_number += 2
		#start of book
		return
	desired_center_page_flip = 1.0
	center_page_flip = 0.0
	load_page_backward()

func load_page_forward() -> void:
	$cover2/pageLeft.text = get_page_safe(page_number-2)
	$centerPage/front.text = get_page_safe(page_number-1)
	$centerPage/back.text = get_page_safe(page_number)
	$cover1/pageRight.text = get_page_safe(page_number+1)

func load_page_backward() -> void:
	$cover2/pageLeft.text = get_page_safe(page_number)
	$centerPage/front.text = get_page_safe(page_number+1)
	$centerPage/back.text = get_page_safe(page_number+2)
	$cover1/pageRight.text = get_page_safe(page_number+3)

func get_page_safe(indx:int) -> String:
	if indx < 0:
		return ""
	elif indx > contents.size()-1:
		return "END"
	else:
		return contents[indx]

const contents = [
	"well hello there!!!\n this is the first page!",
	"hello world, this is the second page!",
	"and the third to be a little unique",
	"alright lets hope you can see this one\n\n\n\n\n         (its the fourth page btw)",
	"and now for my final trick!!!!\n\n\n       THE FIFTH PAGE!!",
	"and the sixth just because :D",
]

