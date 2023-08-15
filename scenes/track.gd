extends Node2D

class_name Track

@onready var tilemap: TileMap = %TileMap
var hints: Array[AIHint]
var length: float = 0
@onready var path: Path2D = $Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	build_hints()

## creates the hints Array with all AIHints
func build_hints():
	for hint in $AIHints.get_children():
		hints.append(hint)
	length = path.curve.get_baked_length()
	

func find_closest_hint_index_to_car(car: Car) -> int:
	var best_score: float = 9000
	var best: int = 0
	for i in hints.size():
		var hint = hints[i]
		var distance: float = car.global_position.distance_to(hint.global_position)
		if distance < best_score:
			best_score = distance
			best = i
	return best

func calculate_car_score(car: Car) -> float:
	var lap_offset: = path.curve.get_closest_offset(car.global_position - path.global_position)
	return lap_offset + car.laps * length
#	return length - calculate_car_distance_left(car) + max(car.laps, 0) * length
