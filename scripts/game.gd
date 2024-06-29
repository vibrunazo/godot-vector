## Game autoload with global values and functions
extends Node

var cell_size := 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('ini game.gd')
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_speed"):
		toggle_debug_speed()

func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2i:
	return Vector2(round(p.x / cell_size), round(p.y / cell_size))

func toggle_debug_speed():
	if Engine.time_scale > 1:
		Engine.time_scale = 1
	else:
		Engine.time_scale = 10

## Calculates score of given car on given track. Score is used to tell which car is head
func calculate_car_score(car: Car, track: Track) -> float:
	var path := track.path
	var lap_offset: = path.curve.get_closest_offset(car.global_position - path.global_position)
	var score: float = lap_offset + car.laps * track.length
	return score
