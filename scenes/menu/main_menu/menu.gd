extends Control


@onready var singleplayer: Control = $singleplayer
@onready var multiplayer_menu: Control = $multiplayer_menu
@onready var settings: TabContainer = $settings


func _on_levels_pressed() -> void:
	singleplayer.show()


func _on_multiplayer_pressed() -> void:
	multiplayer_menu.show()


func _on_settings_pressed() -> void:
	settings.show()


func _on_quit_pressed():
	get_tree().quit()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
