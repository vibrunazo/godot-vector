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

## returns the index of the next point in the path curve after where
## the car is. Used by AI to know where to aim next.
## ahead: how far ahead from where I actually am should I find the next point from
func find_next_hint(car: Car, ahead: float = 0.0) -> int:
	var lap_offset: = path.curve.get_closest_offset(car.global_position - path.global_position)
	lap_offset += ahead
#	var v = path.curve.get_point_position(1) + path.global_position
	var next_i: int = 1
#	var next = path.curve.get_point_position(1)
	for i in path.curve.get_point_count():
		if i == 0: continue
		if i == path.curve.get_point_count() - 1: break
		var point = path.curve.get_point_position(i)
		var off = path.curve.get_closest_offset(point)
#		print('i: %d, point: %s, off: %s' % [i, point, off])
		if off > lap_offset:
			next_i = i
#			next = point
			break
#	print('%s offset: %s, next: %d' % [car.name, lap_offset, next_i])
#	return next + path.global_position
	return next_i

## returns the global position of the hint with given index
func get_loc_of_hint(i: int) -> Vector2:
	return path.curve.get_point_position(i) + path.global_position

## returns the global position of the point ahead of given index by this percentage
## if ahead = 1, returns the next control point
func sample_point_ahead(i: int, ahead: float) -> Vector2:
	return path.curve.sample(i, ahead) + path.global_position
	

func calculate_car_score(car: Car) -> float:
	var lap_offset: = path.curve.get_closest_offset(car.global_position - path.global_position)
	return lap_offset + car.laps * length
#	return length - calculate_car_distance_left(car) + max(car.laps, 0) * length
