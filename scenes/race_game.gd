extends Node

class_name RaceGame

@export var cars: Array[Car]
@export var cam: RaceCam
var turn = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.6).timeout
	start_game()

func start_game():
	var car: Car = get_car_this_turn()
	if not car.is_registered:
		await car.registered
	car.turn_begin()

func _input(event):
	if event.is_action("ui_down_left") and not event.is_pressed():
		input_move(Vector2(-1, 1))
	if event.is_action("ui_down") and not event.is_pressed():
		input_move(Vector2(0, 1))
	if event.is_action("ui_down_right") and not event.is_pressed():
		input_move(Vector2(1, 1))
		
	if event.is_action("ui_left") and not event.is_pressed():
		input_move(Vector2(-1, 0))
	if event.is_action("ui_center") and not event.is_pressed():
		input_move(Vector2(0, 0))
	if event.is_action("ui_right") and not event.is_pressed():
		input_move(Vector2(1, 0))
	
	if event.is_action("ui_up_left") and not event.is_pressed():
		input_move(Vector2(-1, -1))
	if event.is_action("ui_up") and not event.is_pressed():
		input_move(Vector2(0, -1))
	if event.is_action("ui_up_right") and not event.is_pressed():
		input_move(Vector2(1, -1))

func input_move(v: Vector2):
	var car: Car = get_car_this_turn()
	var r = car.input_move(v)
	if r:
		await car.turn_end 
		next_turn()
#	await get_tree().create_timer(1.0).timeout

func next_turn():
	turn += 1
	var car = get_car_this_turn()
	cam.car = car
	car.turn_begin()

## returns the car who plays in this turn
func get_car_this_turn() -> Car:
	return cars[turn % cars.size()]
