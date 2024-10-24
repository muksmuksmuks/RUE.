extends Control



func _on_level_1_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_1/level_1.tscn")


func _on_test_field_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/main/main.tscn")



func _on_x_pressed():
	self.hide()
