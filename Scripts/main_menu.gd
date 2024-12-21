extends Control

@export_group("Buttons")
@export var new_game_button : Button
@export var load_button : Button
@export var save_button : Button
@export var settings_button : Button
@export var exit_button : Button

var level : Node

func _ready() -> void:
	get_tree().paused = true
	new_game_button.call_deferred("grab_focus")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("game_menu"):
		if level:
			get_tree().paused = not get_tree().paused
	
	if get_tree().paused:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func create_new_game():
	if level:
		level.queue_free()
	
	level = load("res://Levels/map_1.tscn").instantiate()
	add_child(level)
	hide()
	get_tree().paused = false

func exit_game():
	get_tree().quit()

func delete_confirmation_dialog(conf : ConfirmationDialog):
	if conf:
		conf.queue_free()

func _on_visibility_changed() -> void:
	if visible:
		new_game_button.call_deferred("grab_focus")


func _on_new_game_button_pressed() -> void:
	create_new_game()


func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	var conf : ConfirmationDialog = ConfirmationDialog.new()
	add_child(conf)
	
	conf.visible = true
	conf.position = (get_window().size - conf.size) / 2
	
	conf.dialog_text = "Do you want to quit?"
	
	conf.get_ok_button().text = "Yes"
	conf.get_ok_button().pressed.connect(exit_game)
	
	conf.get_cancel_button().text = "No"
	conf.get_cancel_button().call_deferred("grab_focus")
	conf.get_cancel_button().pressed.connect(delete_confirmation_dialog.bind(conf))
	
	conf.canceled.connect(delete_confirmation_dialog.bind(conf))
