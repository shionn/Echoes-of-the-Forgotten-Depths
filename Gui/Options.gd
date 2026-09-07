class_name Options
extends Node

enum DamageDisplayMode { FLOAT, CONSOLE, BOTH }

signal applied()

var _options : Dictionary = {}

func _init() -> void:
	load_to_file()

func _ready() -> void:
	apply()
#	get_window().get_viewport().size_changed.connect(_on_size_changed)

func _on_size_changed() -> void : 
	print("viewport %d,%d"%[get_window().get_viewport().get_visible_rect().size.x, get_window().get_viewport().get_visible_rect().size.y])
	print("DisplayServer %d,%d"%[DisplayServer.window_get_size().x, DisplayServer.window_get_size().y])
	#DisplayServer.window_set_size()


func load_to_file() -> void:
	var file_name = "user://options.save"
	if FileAccess.file_exists(file_name) :
		var file = FileAccess.open(file_name, FileAccess.READ)
		_options = JSON.parse_string(file.get_as_text())
		file.close()

func save_to_file() -> void:
	var json_string = JSON.stringify(_options, "\t")
	var file = FileAccess.open("user://options.save", FileAccess.WRITE)
	file.store_line(json_string)
	file.close()

func apply_and_save() -> void:
	apply()
	save_to_file()

func apply() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), get_audio_backbround_vol() )
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effet"),      get_audio_effect_vol())

	if is_fullscreen() : get_window().mode = Window.MODE_FULLSCREEN
	else :               get_window().mode = Window.MODE_WINDOWED

	get_viewport().scaling_3d_scale = get_video_scale()
	get_viewport().scaling_3d_mode  = get_video_scale_mode()

	DisplayServer.window_set_vsync_mode(get_vsync_mode())

	var env  = $"/root/World/Dungeon/Environment" as WorldEnvironment
	env.environment.ssao_enabled = is_ssao_enable()
	
	get_viewport().get_camera_3d().fov = get_video_fov()
	
	_apply_input("move_front", KEY_Z)
	_apply_input("move_back", KEY_S)
	_apply_input("move_left", KEY_Q)
	_apply_input("move_right", KEY_D)
	_apply_input("open_quest", KEY_J)
	_apply_input("open_bag", KEY_I)
	_apply_input("menu", KEY_ESCAPE)
	_apply_input("spell_1", KEY_AMPERSAND)
	_apply_input("spell_2", KEY_2)
	_apply_input("spell_3", KEY_QUOTEDBL)
	_apply_input("spell_4", KEY_APOSTROPHE)
	
	applied.emit()
	
func _apply_input(action : String, default : Key) -> void :
	for input in InputMap.action_get_events(action) :
		if input is InputEventKey :
			(input as InputEventKey).keycode = get_input_key(action,default)

func get_input_key_char(action: String, default : Key) -> String: 
	var key = get_input_key(action, default)
	match key :
		KEY_AMPERSAND : return "1"
		KEY_QUOTEDBL : return "3"
		KEY_APOSTROPHE : return "4"
		_ : return OS.get_keycode_string(key)



func get_audio_backbround_vol() -> float : return _options.get_or_add("audio-background-value", -24.0)
func get_audio_effect_vol()     -> float : return _options.get_or_add("audio-effect-value", 0.0)
func is_fullscreen()            -> bool  : return _options.get_or_add("video-fullscreen", false)
func get_video_scale()          -> float : return _options.get_or_add("video-scale", 1.0)
func get_video_scale_mode()     -> Viewport.Scaling3DMode : return _options.get_or_add("video-scale-mode", Viewport.SCALING_3D_MODE_BILINEAR)
func get_vsync_mode()           -> DisplayServer.VSyncMode : return _options.get_or_add("video-vsync", DisplayServer.VSYNC_ENABLED)
func is_ssao_enable()           -> bool  : return _options.get_or_add("video-ssao", true)
func get_video_fov()            -> float : return _options.get_or_add("video-fov", 75.0)
func get_mouse_sensib()         -> float : return _options.get_or_add("mouse-sensib", 1.0)
func is_mouse_y_invert()        -> bool : return _options.get_or_add("mouse-y-invert", false)
func get_input_key(action: String, default : Key) -> Key: return _options.get_or_add("input-%s"%action, default)
func get_damage_display()       -> DamageDisplayMode : return _options.get_or_add("interface-damage-display", DamageDisplayMode.FLOAT)
func is_floating_damage_display()-> bool : return get_damage_display() != DamageDisplayMode.CONSOLE
func is_console_damage_display() -> bool : return get_damage_display() != DamageDisplayMode.FLOAT

func set_audio_backbround_vol(value: float) -> void : _options.set("audio-background-value", value)
func set_audio_effect_vol(value: float) -> void : _options.set("audio-effect-value", value)
func set_fullsceen(value: bool) -> void : _options.set("video-fullscreen", value)
func set_video_scale(value: float) -> void : _options.set("video-scale", value)
func set_video_scale_mode(value: Viewport.Scaling3DMode) -> void : _options.set("video-scale-mode", value)
func set_vsync_mode(value: DisplayServer.VSyncMode) -> void : _options.set("video-vsync", value)
func set_ssao(value: bool) -> void : _options.set("video-ssao", value)
func set_video_fov(value: float) -> void : _options.set("video-fov", value)
func set_input_key(action_name: String, keycode : Key) : _options.set("input-%s"%action_name, keycode)
func set_damage_display(mode: DamageDisplayMode) -> void : _options.set("interface-damage-display", mode) 
func set_mouse_sensib(value: float) -> void: _options.set("mouse-sensib", value)
func set_mouse_y_invert(value: bool) -> void: _options.set("mouse-y-invert", value)
