extends RigidBody2D
class_name Sub

signal dive_end
signal game_over

const MAX_FORCE:float = 50.0
var force:Vector2 = Vector2.ZERO
const MAX_TORQUE:float = 2000.0
var torque:float = 0.0

var light_dir:Vector2
onready var cam:Camera2D = get_node("Camera2D")
onready var chrono_trigger = get_node("chrono_trigger")
var oxygen:int = 100

var last_score:int = 0 # to detect score changing and emit sound etc...
var score:int = 0

onready var fadeAdvice = get_node("LabelAdvice/fadeAdvice")

var lastvel:float = 0.0
var acc:float = 0.0


func _ready():
	Global.playerNode = self
	fadeAdvice.interpolate_property($LabelAdvice, 'modulate', $LabelAdvice.modulate, Color.transparent, 0.8, Tween.TRANS_CUBIC, Tween.EASE_IN)
	

func _draw():
	var color = Color(0.2, 0.8, 1.0)
	
	if oxygen < 15: # red warning
		color = Color(1.0, 0.4, 0.2)
	elif oxygen < 30: # yellow warning
		color = Color(1.0, 0.8, 0.2)
	
	# draw "bubble"
	draw_arc(Vector2.ZERO, 20, PI/100 * oxygen -PI/2, -PI/100 * oxygen -PI/2, 32, color, 2.0)
	

func _process(delta):
	if force != Vector2.ZERO:
		light_dir = lerp(light_dir, force.normalized().rotated(-PI/2), 6 * delta)
		$Light2D.rotation = light_dir.angle()
	
	var vel = linear_velocity.length()
	cam.zoom = lerp(cam.zoom, Vector2(0.7 + 0.01 * vel, 0.7 + 0.01 * vel), delta)
	cam.position = lerp(cam.position, linear_velocity, 10 * delta)
	
	if position.y - Global.TRIGGER_DEPTH > score:
		fadeAdvice.start()
		score = position.y - Global.TRIGGER_DEPTH
		$Label.text = str(score)
	
	if score > last_score:
		if !Global.audioNode.get_node("score_click").playing:
			Global.audioNode.get_node("score_click").play()
		last_score = score
	
	Global.audioNode.get_node("water_flow").pitch_scale = 0.2 + 0.002 * linear_velocity.length()
	
	acc = linear_velocity.length() - lastvel
	lastvel = linear_velocity.length()
	
	if abs(acc) > 6 && !Global.audioNode.get_node("damage").playing:
		Global.audioNode.get_node("damage").play()
	

func _physics_process(delta):
	if is_above_min_depth():
		apply_central_impulse(Vector2(0, 49) * delta) # some gravity

	if abs(position.x) >= Global.MAX_LATERAL_DIST:
		$lateralWarning.modulate = lerp($lateralWarning.modulate, Color.white, 10 * delta)
		var dir = -position.project(Vector2.RIGHT).normalized().x
		apply_central_impulse(Vector2(49 * dir, 0) * delta)

	else:
		$lateralWarning.modulate = lerp($lateralWarning.modulate, Color.transparent, 10 * delta)

	apply_central_impulse(_get_controls_force() * delta)
	apply_torque_impulse(_get_antirotate_torque() * delta)


func is_above_virtual_surface()->bool:
	if position.y < Global.TRIGGER_DEPTH:
		return true
	
	return false


func is_above_min_depth()->bool:
	if position.y < Global.MIN_DEPTH:
		return true
	
	return false


func _get_controls_force()->Vector2:
	force = Vector2.ZERO
	
	if Global.joystickNode.is_working:
		force = Global.joystickNode.output
		if force.x >= 0.5:
			$leftThruster.emitting  = true
		else:
			$leftThruster.emitting  = false
		if force.x <= -0.5:
			$rightThruster.emitting = true
		else:
			$rightThruster.emitting  = false
		if force.y >= 0.5:
			$upThruster.emitting = true
		else:
			$upThruster.emitting  = false
			
	elif !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_down"):
		$leftThruster.emitting = false
		$rightThruster.emitting = false
		$upThruster.emitting = false
		
	
	
	if Input.is_action_pressed("ui_left"):
		force += Vector2.LEFT
	if Input.is_action_pressed("ui_up"):
		force += Vector2.UP
	if Input.is_action_pressed("ui_right"):
		force += Vector2.RIGHT
	if Input.is_action_pressed("ui_down"):
		force += Vector2.DOWN
	
	force = force.normalized() #to avoid direction > 1
	force *= MAX_FORCE
	
	if force != Vector2.ZERO && !Global.audioNode.get_node("propeller").playing:
		Global.audioNode.get_node("propeller").play()
	elif force == Vector2.ZERO:
		Global.audioNode.get_node("propeller").stop()
	
	return force


func _get_antirotate_torque()->float:
	torque = Vector2.RIGHT.rotated(rotation).cross(Vector2.RIGHT)
	torque *= MAX_TORQUE
	
	return torque


func _input(event):
	if event.is_action_pressed("ui_left"):
		$rightThruster.emitting = true
	elif event.is_action_released("ui_left"):
		$rightThruster.emitting = false
	if event.is_action_pressed("ui_right"):
		$leftThruster.emitting = true
	elif event.is_action_released("ui_right"):
		$leftThruster.emitting = false
	if event.is_action_pressed("ui_down"):
		$upThruster.emitting = true
	elif event.is_action_released("ui_down"):
		$upThruster.emitting = false


func _on_chrono_trigger_timeout():
	update()
	if !is_above_virtual_surface():
		
		if oxygen > 0:
			oxygen -= 1
			if Global.audioNode.get_node("metal_tick").pitch_scale >= 0.69:
				Global.audioNode.get_node("metal_tick").pitch_scale = 0.68
			else:
				Global.audioNode.get_node("metal_tick").pitch_scale = 0.7
			Global.audioNode.get_node("metal_tick").play()

	else:
		if oxygen < 90:
			emit_signal("dive_end")
		

	if oxygen <= 0:
		chrono_trigger.stop()
		emit_signal("game_over")
	
