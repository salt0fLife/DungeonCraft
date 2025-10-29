extends Node3D

@onready var input : AudioStreamPlayer = $input
var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@export var outputPath : NodePath
@export var indicatorPath : NodePath
@export var mouthPath : NodePath
@export var inputThreshold : float = 0.005
var receiveBuffer : PackedFloat32Array
var enabled = true
var working = false
var recording = false
var reverb = 0.0
var reverb_effect : AudioEffectReverb
var muffled_effect : AudioEffectLowPassFilter
var spectrum : AudioEffectSpectrumAnalyzerInstance#AudioEffectSpectrumAnalyzer

var muffled_addition = 0.0
var occluded = false
const time_to_refresh = 240.0
var refresh_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	settup_audio(get_multiplayer_authority())
	pass # Replace with function body.

var effects_bus_index
var effects_bus_name

func settup_audio(id):
	set_multiplayer_authority(id)
	input = $input
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 1)
		#reverb_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index("Reverb"), 0)
		#muffled_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index("Reverb"), 1)
	effects_bus_index = AudioServer.bus_count
	effects_bus_name = "voiBus#" + str(effects_bus_index)
	AudioServer.add_bus(effects_bus_index)
	AudioServer.set_bus_name(effects_bus_index, effects_bus_name)
	AudioServer.set_bus_send(effects_bus_index, get_node(outputPath).bus)
	get_node(outputPath).bus = effects_bus_name
	get_node(outputPath).play()
	AudioServer.add_bus_effect(effects_bus_index, AudioEffectReverb.new(),0)
	reverb_effect = AudioServer.get_bus_effect(effects_bus_index,0)
	AudioServer.add_bus_effect(effects_bus_index, AudioEffectLowPassFilter.new(),1)
	muffled_effect = AudioServer.get_bus_effect(effects_bus_index,1)
	AudioServer.add_bus_effect(effects_bus_index, AudioEffectSpectrumAnalyzer.new(),0)
	AudioServer.get_bus_effect(effects_bus_index,0).fft_size = AudioEffectSpectrumAnalyzer.FFT_SIZE_256
	if !is_multiplayer_authority():
		spectrum = AudioServer.get_bus_effect_instance(effects_bus_index,0)
	else:
		spectrum = AudioServer.get_bus_effect_instance(2, 2)
	#muffled_effect.cutoff_hz = 870
	#muffled_effect.db = 1
	AudioEffectLowPassFilter.new().cutoff_hz = 10000
	AudioEffectLowPassFilter.new().resonance = 1.0
#	playback = get_node(outputPath).get_stream_playback()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_multiplayer_authority():
		process_mic()
		refresh_timer -= delta
		if refresh_timer < 0.0:
			$input.stop()
			refresh_timer = time_to_refresh
			await get_tree().process_frame
			$input.play()
	else:
		var target_pos = get_viewport().get_camera_3d().global_position - o_ray.global_position
		o_ray.global_position = global_position
		o_ray.target_position = target_pos
		occluded = o_ray.is_colliding()
	if occluded:
		muffled_effect.resonance = 0.08
	else:
		muffled_effect.resonance = 1.0
	var distance = get_averaged_distance()
	reverb_effect.wet = remap(distance-5.0, 0.0, 20.0, 0.0, 1.0)*0.5
	reverb_effect.dry = remap(20.0-distance-5.0, 0.0, 20.0, 0.5, 1.0)+5.0
	reverb_effect.room_size = remap(distance, 0.0, 20.0, 0.2, 1.0)
	get_node(mouthPath).spectrum_to_mouth(spectrum, delta)
	process_voice()

@onready var o_ray = $occlusion_check
@onready var rays = [
	$distance,
	$distance2,
	$distance3,
	$up,
	$back,
	$left,
	$right
]

func get_averaged_distance() -> float:
	var dis = 0.0
	var poi = global_position
	for r in rays:
		if r.is_colliding():
			dis += poi.distance_to(r.get_collision_point())
		else:
			dis += 20.0*Global.inside
	dis = dis / rays.size()
	return dis

func face_distance() -> float:
	return global_position.distance_to(rays[0].get_collision_point())

func process_mic():
	var sterioData : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if sterioData.size() > 0 and enabled:
		#reverb_effect
		get_node(indicatorPath).visible = true
		var data : PackedFloat32Array
		data.resize(sterioData.size()/4)
		var maxAmplitude := 0.0
		for i in range(sterioData.size()/4):
			var value = (sterioData[i*4].x + sterioData[i*4].y) / 2
			maxAmplitude = max(value, maxAmplitude)
			data[i] = value
		if maxAmplitude < inputThreshold:
			return
		#print(data)
		recording = true
		send_data.rpc(data)
	else:
		recording = false
		get_node(indicatorPath).visible = false

func process_voice():
	working = false
	if receiveBuffer.size() <= 0:
		return
	#playback = get_child(0, false).get_stream_playback()
	playback = get_node(outputPath).get_stream_playback()
	if playback == null:
		printerr("ERROR: playback == null in " + str(self))
		return
	for i in range(min(playback.get_frames_available(), receiveBuffer.size())):
		working = true
		playback.push_frame(Vector2(receiveBuffer[0], receiveBuffer[0]))
		receiveBuffer.remove_at(0)

@rpc("any_peer", "call_remote", "unreliable")
func send_data(data : PackedFloat32Array):
	receiveBuffer.append_array(data)
	#print(receiveBuffer.size())
	pass





