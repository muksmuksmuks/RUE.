@tool
extends Control

signal save_external_data

##the file paths for the data files.
const tasks_save_path = "res://addons/To-Do/Data/tasks.json"
const notes_save_path = "res://addons/To-Do/Data/notes.json"

##loading note and task scenes.
const task = preload("res://addons/To-Do/SRC/Task.tscn")
const note = preload("res://addons/To-Do/SRC/Note.tscn")

@onready var task_edit = $"%TaskEdit"
@onready var tasks_v_box = $"%TasksVBox"

@onready var notes_v_box = $"%NotesVBox"


##adds new task
func _on_AddButton_pressed():
	if task_edit.text != "" :
		var ins = task.instantiate()
		ins.content = task_edit.text
		ins.data = {
			"name" : task_edit.text,
			"addition_time" : Time.get_datetime_string_from_system(false, true),
			"state" : "Incompleted",
			"completion_time" : "..."
		}
		tasks_v_box.add_child(ins)
		task_edit.text = ""
		ins.connect("state_changed", sort_tasks)
		ins.connect("content_changed", save_changes)
		sort_tasks()


##sorts the tasks (uncompleted first).
func sort_tasks() :
	save_changes()
	var tasks = _load(tasks_save_path)
	tasks.sort_custom(sort_by_completed)
	#removes unsorted tasks
	for c in tasks_v_box.get_children() :
		c.queue_free()
		await c.tree_exited
	##adds the sorted tasks.
	for t in tasks :
		var copy = task.instantiate()
		copy.content = t.content
		copy.completed = t.completed
		copy.data = t.data
		tasks_v_box.add_child(copy)
		copy.connect("state_changed", sort_tasks)
		copy.connect("content_changed", save_changes)
	save_changes()


##sorts the tasks by completed (uncompleted first).
func sort_by_completed(a, b)-> bool :
	##returns true if a is completed but b isn't.
	if int(a.completed) < int(b.completed) :
		return true
	return false


##adds new note
func _on_NewNoteButton_pressed():
	var ins = note.instantiate()
	notes_v_box.add_child(ins)
	ins.connect("state_changed", save_changes)


##saves data to a file at a given path.
func _save(data, path:String) :
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


##loads data from a given path.
func _load(path:String) :
	var file = FileAccess
	if file.file_exists(path) :
		file = file.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data


func _ready():
	##makes sure every onready var is set.
	for child in get_children() :
		child.connect("ready", child_ready)
	##removes all the tasks(if were).
	for t in tasks_v_box.get_children() :
		t.queue_free()
		await  t.tree_exited
	var tasks_data = _load(tasks_save_path)
	if tasks_data != null :
		##loops trough evry task in the data.
		for t in tasks_data :
			var ins = task.instantiate()
			##sets the task vars to the values stored in the data file.
			ins.completed = t.completed
			ins.content = t.content
			if t.has("data") :
				ins.data = t.data.duplicate()
			
			tasks_v_box.add_child(ins)
			
			ins.connect("state_changed", sort_tasks)
			ins.connect("content_changed", save_changes)
	
	##just the same as above ;)
	for n in notes_v_box.get_children() :
		n.queue_free()
		await n.tree_exited
	var notes_data = _load(notes_save_path)
	if notes_data != null :
		for n in notes_data :
			var ins = note.instantiate()
			ins.content = n.content
			ins.title = n.title
			notes_v_box.add_child(ins)
			ins.connect("state_changed", save_changes)


##saves the data to a file.
func save_changes() :
	##defines an array var for data.
	var tasks_data = []
	if tasks_v_box != null :
		##loops trough every task.
		for t in tasks_v_box.get_children() :
			##gets the data of the task.
			var info = {
				"content" : t.content,
				"completed" : t.completed,
				"data" : t.data.duplicate(),
			}
			if not tasks_data.has(info) :
				##appends the data of the task to the whole data array.
				tasks_data.append(info)
		##saves the data to a file.
		_save(tasks_data, tasks_save_path)
	##just the same as above ;)
	var notes_data = []
	if notes_v_box != null :
		for n in notes_v_box.get_children() :
			var info = {
				"title" : n.title,
				"content" : n.content
			}
			notes_data.append(info)
		_save(notes_data, notes_save_path)


##saves the data before quiting or disabling the plugin.
func _exit_tree():
	save_changes()


func child_ready() -> void :
	task_edit = $"%TaskEdit"
	tasks_v_box = $"%TasksVBox"
	notes_v_box = $"%NotesVBox"
