extends Control

onready var depth_label = get_node("HBoxContainer/MarginContainer/Label")
onready var oxygen_label = get_node("HBoxContainer/MarginContainer2/Label")
onready var score_label = get_node("HBoxContainer/MarginContainer3/Label")

func _process(_delta):
	var depth_text = "%4d" % (0.1 * Global.playerNode.position.y)
	depth_label.text = "Depth:" + depth_text
	
	var oxygen_text = "%4d" % Global.playerNode.oxygen
	oxygen_label.text = "Oxygen:" + oxygen_text
	
	score_label.text = str(Global.playerNode.score)
