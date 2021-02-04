extends Control


func _on_Button_pressed():
	Global.audioNode.get_node("win").play()
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/loading_screen.tscn") != OK:
		print("Error when trying to change scene")


func _on_menu_visibility_changed():
	$VBoxContainer/VBoxContainer/Button.grab_focus()
