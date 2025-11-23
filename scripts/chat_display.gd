extends Control
var typing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("chat", _on_chat_message)
	#$TextEdit.keep_editing_on_text_submit = true
	pass # Replace with function body.


func _on_chat_message(text, personalize = false):
	add_message(text)
	add_message.rpc(text)
	pass


@rpc("call_remote", "reliable")
func add_message(text):
	$RichTextLabel.text += "\n" + text
	pass


func _on_text_edit_text_submitted(new_text):
	Global.send_chat(new_text)
	$TextEdit.text = ""
	#$TextEdit.release_focus()
