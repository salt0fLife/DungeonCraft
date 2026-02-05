extends AudioStreamPlayer


func play_song(file_path : String) -> void:
	stream = load(file_path)
	play()

func stop_the_music() -> void:
	stop()
