extends Camera2D

class_name RaceCam

@export var car: Car


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	follow()

func follow():
	if !car: return
	position = car.position
