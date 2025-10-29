extends Node
var AppID = "2921300"

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)
	Steam.steamInitEx()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()
