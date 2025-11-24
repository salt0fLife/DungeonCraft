extends Control
var typing = false
var time_till_hide = 15.0
var hiding_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("chat", _on_chat_message)
	#$TextEdit.keep_editing_on_text_submit = true
	pass # Replace with function body.


func _on_chat_message(text, personalize = false):
	add_message(text)
	hiding_timer = time_till_hide
	fade_in()
	pass


@rpc("call_remote", "reliable")
func add_message(text):
	$VBoxContainer/RichTextLabel.text += "\n" + text
	pass


func _on_text_edit_text_submitted(new_text):
	if new_text == "":
		return
	Global.send_chat(new_text)
	$VBoxContainer/TextEdit.text = ""
	#$TextEdit.release_focus()

func _process(delta):
	if hiding_timer > 0.0:
		hiding_timer -= delta
	else:
		hiding_timer = 0.0
		fade_out()

func fade_out():
	get_tree().create_tween().tween_property($VBoxContainer/RichTextLabel, "modulate", Color(1.0,1.0,1.0,0.0), 0.25)
	get_tree().create_tween().tween_property($background, "modulate", Color(1.0,1.0,1.0,0.0), 0.25)

func fade_in():
	hiding_timer = time_till_hide
	get_tree().create_tween().tween_property($VBoxContainer/RichTextLabel, "modulate", Color(1.0,1.0,1.0,1.0), 0.25)
	get_tree().create_tween().tween_property($background, "modulate", Color(1.0,1.0,1.0,1.0), 0.25)




