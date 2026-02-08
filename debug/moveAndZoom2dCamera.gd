extends Camera2D


func _input(event):
	if event is InputEventMouseMotion and is_multiplayer_authority():
		if Input.is_action_pressed("lm"):
			position -= event.relative
	if Input.is_action_just_pressed("up"):
		zoom += Vector2(0.1,0.1)
	if Input.is_action_just_pressed("down"):
		zoom -= Vector2(0.1,0.1)
