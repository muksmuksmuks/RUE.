@tool
extends Panel

signal state_changed

@onready var title_edit = $"%Title"
@onready var content_edit = $"%Content"

var title:String
var content:String

func _on_DeleteButton_pressed():
	emit_signal("state_changed")
	queue_free()


func _on_Content_text_changed():
	content = content_edit.text
	emit_signal("state_changed")


func _on_Title_text_changed(new_text):
	title = new_text
	emit_signal("state_changed")


func _ready():
	title_edit.text = title
	content_edit.text = content
	
