extends GameBaseControl

@onready var _full_screen = $PanelC/MarginC/VBoxC/TabC/Affichage/FullScreenB

@onready var _fov_label = $PanelC/MarginC/VBoxC/TabC/Affichage/FovL
@onready var _fov_slide = $PanelC/MarginC/VBoxC/TabC/Affichage/FovHSlider

@onready var _vsync_mode_button = $PanelC/MarginC/VBoxC/TabC/Affichage/VSyncM

@onready var _scale_slide = $PanelC/MarginC/VBoxC/TabC/Affichage/ScaleHSlider
@onready var _scale_label = $PanelC/MarginC/VBoxC/TabC/Affichage/ScaleL
@onready var _scale_mode_button = $PanelC/MarginC/VBoxC/TabC/Affichage/ScaleModeB

@onready var _ssao_button = $PanelC/MarginC/VBoxC/TabC/Affichage/SSAOB

@onready var _music_vol_label = $PanelC/MarginC/VBoxC/TabC/Affichage/MusicL
@onready var _music_slide = $PanelC/MarginC/VBoxC/TabC/Affichage/MusicHSlider

@onready var _effect_vol_label = $PanelC/MarginC/VBoxC/TabC/Affichage/SonL
@onready var _effect_slide = $PanelC/MarginC/VBoxC/TabC/Affichage/SonHSlider

@onready var _damage_log_button = $PanelC/MarginC/VBoxC/TabC/Affichage/DamageM

@onready var _mouse_sensib_label = $"PanelC/MarginC/VBoxC/TabC/Controle/Sensibilité/MouseSensib"
@onready var _mouse_sensib_slider = $"PanelC/MarginC/VBoxC/TabC/Controle/Sensibilité/MouseSensibHSlider"

@onready var _mouse_invert_y = $"PanelC/MarginC/VBoxC/TabC/Controle/Sensibilité/MouseInvertYLB"


func _ready() -> void:
	hide()
	_scale_mode_button.get_popup().id_pressed.connect(_on_scale_mode_id_pressed)
	_vsync_mode_button.get_popup().id_pressed.connect(_on_vsync_mode_id_pressed)
	_damage_log_button.get_popup().id_pressed.connect(_on_damage_log_id_pressed)
	options.applied.connect(_on_applied)


func _on_applied() -> void :
	_music_vol_label.text = "Volume Musique (%ddb)" % options.get_audio_backbround_vol()
	_music_slide.value = options.get_audio_backbround_vol()

	_effect_vol_label.text = "Volume Son (%ddb)" % options.get_audio_effect_vol()
	_effect_slide.value = options.get_audio_effect_vol()
	
	_full_screen.button_pressed = options.is_fullscreen()

	_scale_label.text = "Mise à l'échelle (%.2f)" % options.get_video_scale()
	_scale_slide.value = options.get_video_scale()

	match options.get_video_scale_mode() :
		Viewport.SCALING_3D_MODE_BILINEAR : _scale_mode_button.text = "Linéaire"
		Viewport.SCALING_3D_MODE_FSR : _scale_mode_button.text = "FSR 1"
		Viewport.SCALING_3D_MODE_FSR2 : _scale_mode_button.text = "FSR 2"
		Viewport.SCALING_3D_MODE_METALFX_SPATIAL : _scale_mode_button.text = "Métal FX"
		Viewport.SCALING_3D_MODE_METALFX_TEMPORAL : _scale_mode_button.text = "Métal FX Temporel"
		Viewport.SCALING_3D_MODE_NEAREST : _scale_mode_button.text = "Entière (Nearest)"

	match options.get_vsync_mode() : 
		DisplayServer.VSYNC_ENABLED:  _vsync_mode_button.text = "Activé"
		DisplayServer.VSYNC_ADAPTIVE: _vsync_mode_button.text = "Adaptatif"
		DisplayServer.VSYNC_DISABLED: _vsync_mode_button.text = "Désactivé"

	_ssao_button.button_pressed = options.is_ssao_enable()

	_fov_label.text = "Champ de vision (%d°)"%options.get_video_fov()
	_fov_slide.value = options.get_video_fov()
	
	match options.get_damage_display():
		Options.DamageDisplayMode.FLOAT : _damage_log_button.text = "Flottant"
		Options.DamageDisplayMode.CONSOLE : _damage_log_button.text = "Console"
		Options.DamageDisplayMode.BOTH : _damage_log_button.text = "Les Deux"

	_mouse_sensib_label.text = "Sensibilitée souris (%.2f)"%options.get_mouse_sensib()
	_mouse_sensib_slider.value = options.get_mouse_sensib()
	
	_mouse_invert_y.button_pressed = options.is_mouse_y_invert()

func _on_music_value_changed(value: float) -> void:
	options.set_audio_backbround_vol(value)
	options.apply_and_save()

func _on_son_value_changed(value: float) -> void:
	options.set_audio_effect_vol(value)
	options.apply_and_save()

func _on_close_button_pressed() -> void:
	hide()

func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	options.set_fullsceen(toggled_on)
	options.apply_and_save()

func _on_h_slider_scale_value_changed(value: float) -> void:
	options.set_video_scale(value)
	options.apply_and_save()

func _on_scale_mode_id_pressed(id: int) -> void:
	match id :
		0 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_BILINEAR)
		1 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_FSR)
		2 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_FSR2)
		3 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_METALFX_SPATIAL)
		4 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_METALFX_TEMPORAL)
		5 : options.set_video_scale_mode(Viewport.SCALING_3D_MODE_NEAREST)
	options.apply_and_save()

func _on_shadow_ssao_button_toggled(toggled_on: bool) -> void:
	options.set_ssao(toggled_on)
	options.apply_and_save()

func _on_vsync_mode_id_pressed(id: int) -> void:
	match id : 
		0: options.set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		1: options.set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2: options.set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	options.apply_and_save()


func _on_h_slider_fov_value_changed(value: float) -> void:
	options.set_video_fov(value)
	options.apply_and_save()

func _on_damage_log_id_pressed(id: int) -> void:
	match id:
		0 : options.set_damage_display(Options.DamageDisplayMode.FLOAT)
		1 : options.set_damage_display(Options.DamageDisplayMode.CONSOLE)
		2 : options.set_damage_display(Options.DamageDisplayMode.BOTH)
	options.apply_and_save()


func _on_mouse_sensib_h_slider_value_changed(value: float) -> void:
	options.set_mouse_sensib(value)
	options.apply_and_save()


func _on_mouse_invert_ylb_toggled(toggled_on: bool) -> void:
	options.set_mouse_y_invert(toggled_on)
	options.apply_and_save()
