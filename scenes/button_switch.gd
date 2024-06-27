## A button that switches icon depending on state
class_name ButtonSwitch
extends Button

@export var icons: Array[Texture2D] = []
@export var tooltips: Array[String] = []

var state: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(clicked)
	update_icon()

func inc_state():
	state += 1
	if state >= icons.size():
		state = 0
	update_state(state)

func update_state(new_state: int):
	state = new_state
	update_icon()
	update_tooltip()

func update_icon():
	icon = icons[state]

func update_tooltip():
	tooltip_text = tooltips[state]

func clicked():
	inc_state()
	
