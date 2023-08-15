extends Node

class_name AIDriver

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	print('ini AIDriver')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_turn() -> Vector2i:
	return Vector2i(1, 0)
