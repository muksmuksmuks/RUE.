@tool
extends TabBar

const FocusSavePath = "res://addons/To-Do/Data/focus_timer.json"
const HistorySavePath = "res://addons/To-Do/Data/focus_history.json"

const FocusTask = preload("res://addons/To-Do/SRC/FocusTask.tscn")

enum FocusTypes {
	_Timer,
	_Free
	}

@onready var focus_types = $"%FocusTypes"

@onready var hours = $"%Hours"
@onready var minutes = $"%Minutes"
@onready var seconds = $"%Seconds"
@onready var timer_array := [hours, minutes, seconds]

@onready var time_label = $"%TimeLabel"
@onready var start_focus = $"%StartFocus"
@onready var task_name = $"%TaskName"
@onready var focus_tasks = $"%FocusTasks"

var type:int
var is_focusing := false
var time:float
var start_datetime:Dictionary

var focus_history:Array

func _process(delta) :
	if is_focusing :
		if type == FocusTypes._Timer :
			var time_array = get_time_array(time - calculate_duration(start_datetime))
			if time - calculate_duration(start_datetime) <= 0 :
				OS.alert(task_name.text + " Focus Timer Timeout", "GD To-Do")
				_on_StartFocus_pressed()
			var i = 0
			while i < 3 :
				var j = timer_array[i]
				j.value = time_array[i]
				i += 1
		elif type == FocusTypes._Free :
			time_label.text = get_time_string(get_time_array(calculate_duration(start_datetime)))


func _on_StartFocus_pressed() :
	if task_name.text.is_empty() :
		push_error("GD To-Do: Task Name Is Invalid")
		return
	if is_focusing :
		is_focusing = false
		add_task_to_history()
		clear()
	else :
		match focus_types.current_tab :
			0 :
				type = FocusTypes._Timer
				time = calculate_time()
				if time == 0 :
					push_error("GD To-Do: Time Is Invalid")
					return
			1 :
				type = FocusTypes._Free
				time = 0.0
		
		start_datetime = Time.get_datetime_dict_from_system()
		is_focusing = true
	edit_ui()


func calculate_time() -> int :
	var _hours = hours.value
	var _minutes = minutes.value
	var _seconds = seconds.value
	return (_hours*60*60) + (_minutes*60) + (_seconds)


func calculate_duration(datetime:Dictionary) :
	var current_datetime = Time.get_datetime_dict_from_system()
	var _days = current_datetime.day - datetime.day
	var _hours = current_datetime.hour - datetime.hour
	var _minutes = current_datetime.minute - datetime.minute
	var _seconds = current_datetime.second - datetime.second
	
	return (_days*24*60*60) + (_hours*60*60) + (_minutes*60) + (_seconds)


func get_time_string(time_array:Array) -> String : #time_array -> [h, m, s]
	var final_string = ""
	
	for i in time_array :
		var s = str(i)
		if s.length() == 1 :
			s = "0" + s
		final_string += s + ":"
	#erase the last ":"
	final_string = final_string.erase(final_string.length()-1, 1)
	
	return final_string


func get_time_array(T:int) -> Array :
	var H = int(T/3600.0)
	var M = int((T - (H*3600))/60.0)
	var S = int(T - (H*3600) - (M*60))
	
	return [H, M, S]


func save_data(data, path:String) :
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_data(path:String) :
	var file = FileAccess
	if file.file_exists(path) :
		file = file.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data


func save_external_data() -> void :
	save_timer_data()
	save_focus_history()


func save_timer_data() -> void :
	if not is_instance_valid(task_name) : return
	var data = {
		"is_focusing" : is_focusing,
		"type" : type,
		"start_datetime" : start_datetime,
		"time" : time,
		"task_name" : task_name.text,
	}
	
	save_data(data, FocusSavePath)


func save_focus_history() -> void :
	save_data(focus_history, HistorySavePath)


func _ready() -> void :
	load_timer_data()
	load_history_data()
	edit_ui()


func load_timer_data() -> void :
	var timer_data = load_data(FocusSavePath)
	if timer_data != null :
		type = timer_data.type
		time = timer_data.time
		start_datetime = timer_data.start_datetime
		is_focusing = timer_data.is_focusing
		task_name.text = timer_data.task_name


func load_history_data() -> void :
	var data = load_data(HistorySavePath)
	if data != null :
		focus_history = data
	clear_tasks()
	add_tasks()


func edit_ui() -> void :
	if is_focusing :
		start_focus.text = "Stop Focus"
		task_name.editable = false
		match type :
			FocusTypes._Timer :
				focus_types.set_tab_disabled(1, true)
				set_timer_select_editable(false)
			FocusTypes._Free :
				type = FocusTypes._Free
				focus_types.set_tab_disabled(0, true)
	else :
		start_focus.text = "Start Focus"
		
		focus_types.set_tab_disabled(0, false)
		focus_types.set_tab_disabled(1, false)
		
		set_timer_select_editable(true)
		task_name.editable = true


func set_timer_select_editable(value:bool) -> void :
	for i in timer_array :
		i.editable = value


func add_task_to_history() -> void :
	var data = {
		"name" : task_name.text,
		"start_time" : Time.get_datetime_string_from_datetime_dict(
			start_datetime, true),
			
		"duration" : get_time_string(
			get_time_array(calculate_duration(start_datetime))),
			
		"end_time" : Time.get_datetime_string_from_datetime_dict(
			Time.get_datetime_dict_from_system(), true),
	}
	
	focus_history.append(data)
	save_focus_history()
	load_history_data()


func clear() -> void :
	task_name.text = ""
	for i in timer_array :
		i.value = 0
	time_label.text = get_time_string([0, 0, 0])


func clear_tasks() -> void :
	for i in focus_tasks.get_children() :
		i.queue_free()


func add_tasks() -> void :
	for i in focus_history :
		var task = FocusTask.instantiate()
		task.data = i
		focus_tasks.add_child(task)
		var _err = task.connect("removed", remove_task_from_history)


func remove_task_from_history(data:Dictionary) -> void :
	focus_history.erase(data)
	save_focus_history()
