extends Node2D

func _ready():
	Global.audioNode = get_node("audio")

func _process(_delta):
	var darkness = 1/(Global.DARKNESS_FACTOR * Global.playerNode.position.y + 1)
	get_node("ParallaxBackground/CanvasModulate").color = Color(darkness, darkness, darkness)


func _on_sub_dive_end():
	Global.audioNode.get_node("win").play()
	get_tree().paused = true
	$hud_layer/menu/VBoxContainer/message.text = "Score\n" + str(Global.playerNode.score)
	$hud_layer/menu.visible = true


func _on_sub_game_over():
	Global.audioNode.get_node("game_over").play()
	get_tree().paused = true
	$hud_layer/menu/VBoxContainer/message.text = "Game Over\nOxygen 0%"
	$hud_layer/menu.visible = true
