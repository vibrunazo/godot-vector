extends Resource

class_name BotDriver

@export var difficulty: float = 3
var effective_difficulty: float = 3
var car: Car
var track: Track
var turns_ahead := 0
var turns_behind := 0

# Called when the node enters the scene tree for the first time.
func _init():
#	print('ini BotDriver level %d' % [difficulty])
	pass

func setup(car_ref: Car):
	car = car_ref
	track = car.track
	difficulty = clamp(difficulty, 0, 10)
	effective_difficulty = difficulty
#	print('%s setup BotDriver level %d' % [car.name, difficulty])


func play_turn() -> Vector2i:
	await car.get_tree().create_timer(0.35).timeout
	calc_e_difficulty()
	var ahead: float = calc_ahead()
	var next_i: int = track.find_next_hint(car, ahead)
	var next_pos: = track.get_loc_of_hint(next_i)
	var car_cell := car.grid_pos
	var next_cell := car.pix2grid(next_pos)
	var dist_next := next_cell - car_cell
	var second_next := track.sample_point_ahead(next_i, 1.0)
	var sec_cell := car.pix2grid(second_next)
	var dist_sec := sec_cell - next_cell
	var dir_sec := dist_sec / dist_sec.length()
	var target := next_cell
	if dist_next.length() >= rand_range_diff(70, 35):
		target -= Vector2i(dir_sec * 2)
#	elif dist_next.length() >= 30:
#		target -= Vector2i(dir_sec * 2)
	if dist_next.length() <= rand_range_diff(0, 9):
		target += Vector2i(dir_sec * rand_range_diff(0, 4))
	elif dist_next.length() <= rand_range_diff(0, 20):
		target += Vector2i(dir_sec * rand_range_diff(0, 2))
	var mistake = Vector2(randf_range(-4, 4), randf_range(-4, 4)) * rand_range_diff(1, 0)
	target += Vector2i(mistake)
	var distance: = target - car_cell
	var max_distance := calc_break_distance()
	var input: = distance - max_distance
	if abs(input.x) <= rand_range_diff(0, 2): input.x = 0
	if abs(input.y) <= rand_range_diff(0, 2): input.y = 0
#	input = round(Vector2(input) / max(abs(input.x), abs(input.y)))
	input = input.clamp(Vector2i(-1, -1), Vector2i(1, 1))
#	print('%s pos: %s, next: %s, target: %s, d: %s, md: %s, svector: %s, input: %s, ahead: %d' % [car.name, car_cell, next_cell, target, distance, max_distance, car.svector, input, round(ahead / 16)])
	var will_crash := car.predict_crash(input)
	if will_crash:
		input = -car.svector
		input = input.clamp(Vector2i(-1, -1), Vector2i(1, 1))
		print('will crash: %s, breaking with %s' % [will_crash, input])
	return input

func calc_e_difficulty():
	effective_difficulty = difficulty
	if car.is_ahead_of_player() || car.is_first():
		turns_ahead += 1
		turns_behind = 0
		if turns_ahead >= 8:
			effective_difficulty -= min((turns_ahead - 8) * 0.12, 5)
	else:
		turns_ahead = 0
		turns_behind += 1
		if turns_behind >= 20:
			effective_difficulty += 1
		if turns_behind >= 30:
			effective_difficulty += 1
	if car.is_last():
		effective_difficulty += 3
	effective_difficulty = clamp(effective_difficulty, 1, 10)

## calculate how far ahead
func calc_ahead() -> float:
	var ahead: float = 4 * 16
	if max(abs(car.svector.x), abs(car.svector.y)) >= 3: ahead += 2 * 16
	if max(abs(car.svector.x), abs(car.svector.y)) >= 4: ahead += 2 * 16
	if max(abs(car.svector.x), abs(car.svector.y)) >= 5: ahead += 3 * 16
	if max(abs(car.svector.x), abs(car.svector.y)) >= 6: ahead += 3 * 16
	ahead *= effective_difficulty / 10
	return ahead

## calculate how far ahead the car can fully brake to zero
func calc_break_distance() -> Vector2i:
	var x = sum_to_one(car.svector.x)
	var y = sum_to_one(car.svector.y)
	return Vector2i(x, y)

## returns a random value from best to worst depending on ai difficulty
## max difficulty will always return best, min ai will randomly return any value between best and worst
## mid difficulty returns best half the time
func rand_range_diff(worst, best):
	var rand = randf_range(0, 13)
	rand += effective_difficulty 
	rand /= 10
	# ed: 5
	# returns: 5 - 20
	return lerp(worst, best, min(rand, 1))

# sum of all integers down to 1. 
# example, n=5, 5+4+3+2+1 = 15
# useful for finding how far the car takes to brake to full stop
func sum_to_one(n: int) -> int:
	if n < 0: 
		n *= -1
		@warning_ignore("integer_division")
		return -(n * (n + 1) / 2)
	@warning_ignore("integer_division")
	return n * (n + 1) / 2
# 1 -> 1
# 2 -> 3
# 3 -> 6
# 4 -> 10
# 5 -> 15
# 6 -> 21


