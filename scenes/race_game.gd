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

func clicked():
	var tilemap: TileMap
	tilemap = $"../TileMap"
	var mouse := tilemap.get_local_mouse_position()
	var clicked_cell = tilemap.local_to_map(mouse)
	var data := tilemap.get_cell_tile_data(0, clicked_cell)
	var v := tilemap.map_to_local(clicked_cell)
	var bt := data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)

#	var tile := tilemap.get_cell_tile_data(0, Vector2i(0, 0))
	print("terrain %d at %s v: %s m: %s bt: %s" % [data.terrain, clicked_cell, v, mouse, bt])
#	var p:= get_position_inside_tile(tilemap, clicked_cell, mouse)
	
	
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
