extends Node

class_name RaceGame

@export var cars: Array[Car]
@export var cam: RaceCam
var turn = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
	cam.car = get_car_this_turn()

## returns the car who plays in this turn
func get_car_this_turn() -> Car:
	return cars[turn % cars.size()]
