extends Node

class_name RaceGame

signal update_ui

@export var cam: RaceCam
@export var track: Track
@export var grid: Grid
@export var cars: Array[Car]
var turn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	register_cars()
	await get_tree().create_timer(0.6).timeout
	start_game()

func register_cars():
	for car in cars:
		if car:
			car.finished.connect(on_car_finished)
			car.game = self
			car.track = track
			car.grid = grid

func start_game():
	new_turn()

func clicked():
	var mouse = grid.get_global_mouse_position()
	var cell := grid.pix2grid(mouse)
	print('clicked %s' % [cell])
	
func get_position_inside_tile(tilemap: TileMap, tile_pos: Vector2i, world_pos: Vector2) -> Vector2:
	var v := tilemap.map_to_local(tile_pos)
	var data: TileData = tilemap.get_cell_tile_data(0, tile_pos)
	var tile_size := tilemap.tile_set.tile_size
	var p: Vector2 = world_pos - v + Vector2(tile_size)/2
	var x: int = floor(p.x / (tile_size.x / 3.0)) 
	var y: int = floor(p.y / (tile_size.y / 3.0))
	var dir: int = get_dir_from_relativepos(x, y)
	var bit: int = data.get_terrain_peering_bit(dir)
	data.terrain
	print("relative pos: %s, size: %s, x: %s, y: %s, dir: %s, bit: %s" % [p, tile_size, x, y, dir, bit])
	return p

## returns the direction from the TileSet.CELL_NEIGHBOR Enum 
func get_dir_from_relativepos(x: int, y: int) -> int:
	match [x, y]:
		[0, 0]:
			return TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER
		[1, 0]:
			return TileSet.CELL_NEIGHBOR_TOP_SIDE
		[2, 0]:
			return TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
		[2, 2]:
			return TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
	return 0

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		clicked()
	if event.is_action("ui_down_left") and not event.is_pressed():
		local_input(Vector2(-1, 1))
	if event.is_action("ui_down") and not event.is_pressed():
		local_input(Vector2(0, 1))
	if event.is_action("ui_down_right") and not event.is_pressed():
		local_input(Vector2(1, 1))
		
	if event.is_action("ui_left") and not event.is_pressed():
		local_input(Vector2(-1, 0))
	if event.is_action("ui_center") and not event.is_pressed():
		local_input(Vector2(0, 0))
	if event.is_action("ui_right") and not event.is_pressed():
		local_input(Vector2(1, 0))
	
	if event.is_action("ui_up_left") and not event.is_pressed():
		local_input(Vector2(-1, -1))
	if event.is_action("ui_up") and not event.is_pressed():
		local_input(Vector2(0, -1))
	if event.is_action("ui_up_right") and not event.is_pressed():
		local_input(Vector2(1, -1))

## received an input from a local player
func local_input(v: Vector2):
	var car: Car = get_car_this_turn()
	if not car.control_type == Car.Controller.LOCAL:
		return
	input_move(v)

## inputs a move on current car
func input_move(v: Vector2):
	var car: Car = get_car_this_turn()
	var r = car.input_move(v)
	if r:
		cam.on_car_started_move()
		await car.turn_end 
		next_turn()
#	await get_tree().create_timer(1.0).timeout

func next_turn():
	turn += 1
	new_turn()

func new_turn():
	var car = get_car_this_turn()
	if not car:
		next_turn()
		return
	if not car.is_registered:
		await car.registered
	cam.change_car(car)
	calculate_car_positions()
	request_update_ui()
	car.turn_begin()
	if car.control_type == car.Controller.AI and car.ai:
		var input = car.ai.play_turn()
		input_move(input)

## returns the car who plays in this turn
func get_car_this_turn() -> Car:
	return cars[turn % cars.size()]
	
func calculate_car_positions():
	var sorted_cars: Array[Car] = cars.duplicate()
	sorted_cars.sort_custom(func(a, b): return a.distance_score > b.distance_score)
	var i = 1
	for car in sorted_cars:
		car.race_pos = i
		i += 1

## returns which position this car is in the race
func find_car_position(car: Car) -> int:
	return car.race_pos

# some car crossed the finish line
func on_car_finished():
#	request_update_ui()
	pass
	
func request_update_ui():
	update_ui.emit()
