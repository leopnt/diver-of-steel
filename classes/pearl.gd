extends Area2D

onready var collect_button = get_node("Button")


func _on_pearl_body_entered(_body):
	collect_button.show()


func _on_pearl_body_exited(_body):
	collect_button.hide()


func _on_Button_pressed():
	print(self, " has been collected")
