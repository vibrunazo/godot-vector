extends Node

class_name AIDriver

var car: Car
var track: Track

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	print('ini AIDriver')


func play_turn() -> Vector2i:
	var v := track.find_next_hint(car)
	var car_cell := car.grid_pos
	var next_cell := car.pix2grid(v)
	var input:  = next_cell - car_cell
	input = input.clamp(Vector2i(-1, -1), Vector2i(1, 1))
	print('car pos: %s, next: %s, input: %s' % [car_cell, next_cell, input])
	return input


