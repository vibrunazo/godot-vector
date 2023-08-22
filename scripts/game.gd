extends Node

var cell_size := 64

# Called when the node enters the scene tree for the first time.
func _ready():
	print('ini game.gd')

func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2i:
	return Vector2(round(p.x / cell_size), round(p.y / cell_size))
