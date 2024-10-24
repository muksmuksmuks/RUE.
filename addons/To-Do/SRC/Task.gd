@tool
extends HBoxContainer

signal state_changed
signal content_changed

const InfoBox = preload("res://addons/To-Do/SRC/TaskInfo.tscn")

@export var content:String
@onready var label = $LineEdit
@onready var check_box = $CheckBox
var completed := false
var data:Dictionary

func _ready():
	label.text = content
	check_box.button_pressed = completed
	if data.is_empty() :
		print("data empty")
		data = {
			"name" : content,
			"addition_time" : "...",
			"state" : "Completed" if completed else "Incompleted",
			"completion_time" : "..."
		}
	data.state = "Completed" if completed else "Incompleted"


func _on_CheckBox_toggled(button_pressed):
	if not data.is_empty() :
		if completed :
			data.state = "Completed"
			if data.completion_time == "..." :
				data["completion_time"] = Time.get_datetime_string_from_system(false, true)
		else :
			data.state = "Incompleted"
			if not data.completion_time == "..." :
				data["completion_time"] == "..."
	
	if button_pressed == completed :
		return
	completed = button_pressed
	emit_signal("state_changed")


func _on_DeleteButton_pressed():
#	emit_signal("state_changed")
	queue_free()


func _on_LineEdit_text_changed(new_text):
	if new_text == content :
		return
	content = new_text
	emit_signal("content_changed")


func _on_InfoButton_pressed():
	var ins = InfoBox.instantiate()
	
	if data.is_empty() :
		ins.text = "data isn't available"
	else :
		var text = "Name : %s \n Addition Time : %s \n State : %s \n Completion Time : %s \n"
		var formated_text = text%[data.name, data.addition_time,
		data.state, data.completion_time]
		ins.text = formated_text
	
	$"../../..".add_child(ins)
