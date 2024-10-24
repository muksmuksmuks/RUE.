extends Control

@onready var main = $"../../"

func _on_resume_pressed() -> void:
	main.pauseMenu()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/settings/settings.tscn")

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/main_menu/menu.tscn")
