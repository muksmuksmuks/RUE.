extends Control

#sens
@onready var mouse_sens_slider: HSlider = %MouseSensSlider
@onready var mouse_sens_value_label: Label = %MouseSensValueLabel

var mouse_sens : float

func _on_back_pressed() -> void:
	self.hide()

#GAMEPLAY
func _on_mouse_sens_slider_value_changed(value):
	mouse_sens = value
	mouse_sens_value_label.text = str(value)

#GRAPHICS
func _on_fullscreen_option_button_item_selected(index: int) -> void:
	# To change between winow, fullscreen and other window modes,
	# set the root mode to one of the options of Window.MODE_*.
	# Other modes are maximized and minimized.
	if index == 0: # Disabled (default)
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1: # Fullscreen
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)
	elif index == 2: # Exclusive Fullscreen
		get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))

func _on_limit_fps_slider_value_changed(value: float) -> void:
		# The maximum number of frames per second that can be rendered.
	# A value of 0 means "no limit".
	Engine.max_fps = value

func _on_vsync_option_button_item_selected(index: int) -> void:
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible at the cost of
	# higher input latency and stuttering when the framerate target is not met.
	# Adaptive V-Sync automatically disables V-Sync when the framerate target is not met, and enables
	# V-Sync otherwise. This prevents suttering and reduces input latency when the framerate target
	# is not met, at the cost of visible tearing.
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _on_filter_option_button_item_selected(index: int) -> void:
	# Viewport scale mode setting.
	if index == 0: # Bilinear (Fastest)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0.
		%FSRSharpnessLabel.visible = false
		%FSRSharpnessSlider.visible = false
	elif index == 1: # FSR 1.0 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0.
		%FSRSharpnessLabel.visible = true
		%FSRSharpnessSlider.visible = true

func _on_fsr_sharpness_slider_value_changed(value: float) -> void:
	# Lower FSR sharpness values result in a sharper image.
	# Invert the slider so that higher values result in a sharper image,
	# which is generally expected from users.
	get_viewport().fsr_sharpness = 2.0 - value

func _on_taa_option_button_item_selected(index: int) -> void:
	# Temporal antialiasing. Smooths out everything including specular aliasing, but can introduce
	# ghosting artifacts and blurring in motion. Moderate performance cost.
	get_viewport().use_taa = index == 1

func _on_msaa_option_button_item_selected(index: int) -> void:
		# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
	# transparent (alpha scissor) textures.
	if index == 0: # Disabled (default)
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X

func _on_fxaa_option_button_item_selected(index: int) -> void:
	# Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha scissor edges),
	# but blurs the whole scene rendering slightly.
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA


#AUDIO
func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0,value)


#KEY BINDINGS
