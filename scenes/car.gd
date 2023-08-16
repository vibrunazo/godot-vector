extends Node2D

class_name Car

signal started_move
signal turn_end
signal registered
signal finished

enum Controller {LOCAL, AI}

@export var color: Color = Color(0.9, 0.2, 0.2)
@export var control_type: Controller = Controller.LOCAL
@export var ai: BotDriver
var game: RaceGame
var track: Track
var grid: Grid
var grid_pos := Vector2i(0, 0)
var ini_grid_pos := Vector2i(0, 0)
var cell_size := 16
var next_move := Vector2i(0, 0)
## current speed vector
var svector := Vector2i(0, 0)
var history: Array[Vector2i]
var car_history: CarHistory
var is_moving: = false
var is_my_turn: = false
var is_registered: = false
var is_crashed: = false
var tween_move: Tween
var laps: int = -1
# how far I've travelled, to calculate who is ahead
var distance_score: float = 0
# my position in the race, set by the RaceGame each turn
var race_pos: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	%SelectionSprite.modulate = color
	if grid:
		cell_size = grid.cell_size
	update_grid_from_pos()
	ini_grid_pos = grid_pos
	register_car_history()
	update_pos_from_grid()
	update_draw()
	calculate_distance_score()
	setup_ai()
	is_registered = true
	registered.emit()

func register_car_history():
	car_history = %CarHistory
	car_history.car = self
	var parent = get_parent()
	var vecs = parent.get_node("%Vectors")
	if vecs: parent = vecs
	car_history.reparent.call_deferred(parent, false)
	car_history.build_dots()
#	car_history.update_vectors()

func setup_ai():
	if control_type == Controller.AI:
		if not ai:
			ai = load("res://res/bot_driver.tres")
		ai.car = self
		ai.track = track

## updates history vectors and target dots
func update_draw():
	if car_history:
		car_history.update_vectors()
		car_history.update_dots_at(grid_pos + svector)

## my turn begins
## the RaceGame tells the Car when its turn begins, 
## but the Car tells the Game when the turn ends via turn_end signal
func turn_begin():
	is_my_turn = true
	car_history.show_dots()
	$Anim.play("selected")
	%SelectionSprite.visible = true
#	apply_terrain_mod()

func apply_terrain_mod():
	var terrain = get_terrain_here()
	if terrain == 1:
		svector.x = 0
		svector.y = 0

func get_terrain_here() -> int:
	var tilemap: TileMap
	tilemap = track.tilemap
#	var mouse := tilemap.get_local_mouse_position()
	var local_pos := global_position - tilemap.global_position
	var cell = tilemap.local_to_map(local_pos)
	var data := tilemap.get_cell_tile_data(0, cell)
#	print('cell: %s terrain: %s' % [cell, data.terrain])
	return data.terrain
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
	
func input_move(v: Vector2) -> bool:
	if is_moving: return false
	if not is_my_turn: return false
	next_move = v
	move()
	return true

func move():
	svector += next_move
	move_to(grid_pos + svector)
#	move_to(Vector2i(20,10))
	car_history.show_target_at(grid_pos + svector)
	car_history.hide_dots()

func move_to(new_pos: Vector2i):
	is_moving = true
	started_move.emit()
	%SelectionSprite.visible = false
	tween_move = create_tween()
	tween_move.tween_property(self, "position", grid2pix(new_pos), 0.8)
	tween_move.tween_callback(on_move_end)

func update_pos_from_grid():
	position = grid2pix(grid_pos)
#	car_history.update_vectors()

func calculate_distance_score():
	distance_score = track.calculate_car_score(self)

func on_move_end():
	is_moving = false
#	car_history.update_vectors()
#	if is_crashed: return
	grid_pos += svector
	calculate_distance_score()
	history.append(svector)
	apply_terrain_mod()
	turn_end.emit()
	update_draw()
	car_history.hide_target()
	is_crashed = false
	is_my_turn = false

func update_grid_from_pos():
	grid_pos = pix2grid(global_position)

func crash():
	is_crashed = true
	tween_move.stop()
	svector = Vector2i(0, 0)
	## TODO play crash anim here
	update_pos_from_grid()
	on_move_end()

## enters the finish line
func finish_enter():
	if svector.x > 0:
		laps += 1
	else:
		pass
#	print('%s finished, laps: %d' % [name, laps])
	finished.emit()

## exits finish line
func finish_exit():
	if svector.x > 0:
		pass
	else:
		laps -= 1
#	print('%s finish exited, laps: %d' % [name, laps])
	finished.emit()

#TODO should be a global or something idk
func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2i:
	return Vector2(round(p.x / cell_size), round(p.y / cell_size))


func _on_area_2d_body_entered(_body):
	crash()

func _on_area_2d_area_entered(area):
	if area.get_parent() is FinishLine: finish_enter()
	elif is_my_turn and is_moving and area.get_parent() is Car: crash()

func _on_area_2d_area_exited(area):
	if area.get_parent() is FinishLine: finish_exit()
