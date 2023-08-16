extends Resource

class_name BotDriver

@export var difficulty: int = 5
var car: Car
var track: Track

# Called when the node enters the scene tree for the first time.
func _init():
	print('ini BotDriver level %d' % [difficulty])

func setup(car_ref: Car):
	car = car_ref
	track = car.track
	difficulty = clamp(difficulty, 0, 10)
	print('%s setup BotDriver level %d' % [car.name, difficulty])


func play_turn() -> Vector2i:
	var ahead = 120.0 
	if max(car.svector.x, car.svector.y) >= 4: ahead += 20.0
	if max(car.svector.x, car.svector.y) >= 5: ahead += 60.0
	if max(car.svector.x, car.svector.y) >= 6: ahead += 40.0
	ahead *= float(difficulty) / 10
	var v := track.find_next_hint(car, ahead)
	var car_cell := car.grid_pos
	var next_cell := car.pix2grid(v)
	var distance: = next_cell - car_cell
	var max_distance := calc_break_distance()
	var input: = distance - max_distance
	input = input.clamp(Vector2i(-1, -1), Vector2i(1, 1))
	print('%s pos: %s, next: %s, d: %s, md: %s, svector: %s, input: %s' % [car.name, car_cell, next_cell, distance, max_distance, car.svector, input])
	return input

## calculate how far ahead the car can fully brake to zero
func calc_break_distance() -> Vector2i:
	var x = sum_to_one(car.svector.x)
	var y = sum_to_one(car.svector.y)
	return Vector2i(x, y)

# sum of all integers down to 1. 
# example, n=5, 5+4+3+2+1 = 15
# useful for finding how far the car takes to brake to full stop
func sum_to_one(n: int) -> int:
	if n < 0: 
		n *= -1
		print('n: %d, sum: %d, psum: %d' % [n, -(n * (n + 1) / 2), (n * (n + 1) / 2)])
		return -(n * (n + 1) / 2)
	return n * (n + 1) / 2
# 1 -> 1
# 2 -> 3
# 3 -> 6
# 4 -> 10
# 5 -> 15
# 6 -> 21

