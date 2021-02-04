extends Control

onready var fake_load_percent = 0

func _ready():
	randomize()


func _process(_delta):
	var ran_n = int(rand_range(0.0, 16.0))
	if ran_n % 4 == 0:
		fake_load_percent += ran_n + rand_range(0.0, 2.0) # add some randomness
	update_percent(fake_load_percent)


func update_percent(new_percent):
	get_node("MarginContainer/VBoxContainer/ProgressBar").value = new_percent

	if new_percent >= $MarginContainer/VBoxContainer/ProgressBar.max_value:
		if get_tree().change_scene("res://scenes/main.tscn") != OK:
			print("Error during scene loading")
