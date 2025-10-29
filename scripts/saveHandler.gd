extends Node
const rootFolder = "res://tempSaveFolder/"#"user://saves/"
var saveFolderName = "save1"
var savePath = "res://"#"user://"
var lastDate = "N/A"
var date = ""


func _ready():
	date = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(false), false)
	savePath = rootFolder + saveFolderName + "/"
	save_date()

func save_date() -> void:
	if !DirAccess.dir_exists_absolute(savePath):
		DirAccess.make_dir_recursive_absolute(savePath)
	var datePath = (savePath + "date.dat")
	if FileAccess.file_exists(datePath):
		var readFile = FileAccess.open(datePath, FileAccess.READ)
		lastDate = readFile.get_var()
		readFile.close()
	var writeFile = FileAccess.open(datePath, FileAccess.WRITE)
	writeFile.store_var(date)
	writeFile.close
	print("last opened " + str(lastDate) + "\n" + "currently " + str(date))
	return

func save_file(subFolder : String, fileName : String, data) -> void:
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		DirAccess.make_dir_recursive_absolute(savePath+subFolder)
	var path = savePath+subFolder+fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("saved " + fileName)

func load_file(subFolder : String, fileName : String):
	var path = savePath+subFolder+fileName
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		printerr("tried to load from nonexistant directory")
		return null
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("loaded " + fileName)
		return data
	else:
		printerr("tried to load nonexistant file")
		return null

func get_saves_list() -> Array:
	var saves = []
	if !DirAccess.dir_exists_absolute(rootFolder):
		DirAccess.make_dir_recursive_absolute(rootFolder)
		print("first time loaded, setting up directories")
	for f in DirAccess.get_directories_at(rootFolder):
		saves += [f]
	return saves
