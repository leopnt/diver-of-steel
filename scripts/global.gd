extends Node

var playerNode:Sub
var joystickNode:Joystick
var audioNode:Node

const MIN_DEPTH:int = 250
const TRIGGER_DEPTH:int = 310 # for timer start and score update

const MAX_LATERAL_DIST:int = 1500

const DARKNESS_FACTOR:float = 0.005
