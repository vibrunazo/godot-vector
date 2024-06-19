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
@onready var car_sprite: Sprite2D = %CarSprite
@onready var selection_sprite: Sprite2D = %SelectionSprite
var anim_speed = 0.5
var game: RaceGame
var track: Track
var grid: Grid
var grid_pos := Vector2i(0, 0)
var ini_grid_pos := Vector2i(0, 0)
var cell_size := 64
var next_move := Vector2i(0, 0)
## current speed vector
var svector := Vector2i(0, 0)
var history: Array[Vector2i]
var car_history: CarHistory
var car_shadows: CarHistory
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
	selection_sprite.modulate = color
	car_sprite.modulate = color
	car_sprite.modulate.v -= 0.05
	if grid:
		cell_size = grid.cell_size
	update_grid_from_pos()
	ini_grid_pos = grid_pos
	register_car_history()
	update_pos_from_grid()
	update_draw()
	calculate_distance_score()
	setup_ai()
	$ShapeCast2D.add_exception($Area2D)
	is_registered = true
	registered.emit()

func register_car_history():
	car_history = %CarHistory
	car_history.car = self
	car_history.is_shadow = false
	var parent = get_parent()
	var vecs = parent.get_node("%Vectors")
	if vecs: parent = vecs
	car_history.reparent.call_deferred(parent, false)
	car_history.build_dots()
	
	car_shadows = %CarShadows
	car_shadows.car = self
	parent = get_parent().get_node("%VectorsShadows")
	car_shadows.reparent.call_deferred(parent, false)

func setup_ai():
	if control_type == Controller.AI:
		if not ai:
			ai = load("res://res/bot_driver.tres").duplicate()
		ai.setup(self)

## updates history vectors and target dots
func update_draw():
	if car_history:
		car_history.update_vectors()
		car_history.update_dots_at(grid_pos + svector)
	if car_shadows:
		car_shadows.update_vectors()

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
	var terrain: int = get_terrain_here()
	if terrain == 1:
		svector.x = 0
		svector.y = 0

# the type of terrain the car is currently standing on
# returns 1 for grass, 0 for road
func get_terrain_here() -> int:
	var tilemap: TileMap
	tilemap = track.tilemap
#	var mouse := tilemap.get_local_mouse_position()
	var local_pos := global_position - tilemap.global_position
	var cell = tilemap.local_to_map(local_pos)
	var data := tilemap.get_cell_tile_data(0, cell)
	var is_inside: bool = false
	var count := data.get_collision_polygons_count(0)
	if count == 0: return 0
	for i in range(0, count):
		var poly := data.get_collision_polygon_points(0, i)
		var cell_pos := tilemap.map_to_local(cell) + tilemap.global_position
		var car_r_pos := global_position - cell_pos
		if poly.size() > 2:
			is_inside = Geometry2D.is_point_in_polygon(car_r_pos, poly)
#		print('car %s, i: %d of %d, pos: %s, car_r_pos: %s poly: %s, in: %s' % [name, i, count, cell_pos, car_r_pos, poly, is_inside])
	#	print('cell: %s terrain: %s' % [cell, data.terrain])
		if is_inside: return 1
	return 0
#	return data.terrain
	
func input_move(v: Vector2i) -> bool:
	if is_moving: return false
	if not is_my_turn: return false
	next_move = v
	move()
	return true

func move():
	svector += next_move
	$AudioVroom.pitch_scale = 0.8 + svector.length() * 0.05
	$AudioVroom.play()
	if game.turn % 2: $AudioVroom2.play()
	else: $AudioVroom3.play()
	
	move_to(grid_pos + svector)
#	move_to(Vector2i(20,10))
	car_history.show_target_at(grid_pos + svector)
	car_history.hide_dots()

func move_to(new_pos: Vector2i):
	is_moving = true
	started_move.emit()
	%SelectionSprite.visible = false
	tween_move = create_tween()
	tween_move.tween_property(self, "position", grid2pix(new_pos), anim_speed)
	tween_move.tween_callback(on_move_end)

func update_pos_from_grid():
	position = grid2pix(grid_pos)
#	car_history.update_vectors()

func calculate_distance_score():
	distance_score = track.calculate_car_score(self)

func on_move_end():
	await get_tree().create_timer(0.05).timeout
#	car_history.update_vectors()
	if is_crashed:
		return
	grid_pos += svector
	calculate_distance_score()
	history.append(svector)
	apply_terrain_mod()
	
	end_turn()
	

func end_turn():
	update_draw()
	car_history.hide_target()
	turn_end.emit()
	is_moving = false
	is_crashed = false
	is_my_turn = false

func update_grid_from_pos():
	grid_pos = pix2grid(global_position)

func is_ahead_of_player() -> bool:
	return game.is_car_ahead_of_player(self)

## Returns whether this Car is placed first in the race
func is_first() -> bool:
	return race_pos == 1

## Returns whether this Car is placed last in the race
func is_last() -> bool:
	return race_pos == game.cars.size()

## Returns true if using given input this turn would crash.
## false otherwise
func predict_crash(input: Vector2i) -> bool:
	var next := svector + input
	$ShapeCast2D.target_position = grid2pix(next)
	$ShapeCast2D.force_shapecast_update()
	if $ShapeCast2D.is_colliding():
		var col = $ShapeCast2D.get_collider(0)
		print('col: %s' % [col.get_parent()])
	return $ShapeCast2D.is_colliding()

func crash():
	print('%s crashed' % [name])
	is_crashed = true
	tween_move.stop()
	svector = Vector2i(0, 0)
	## TODO play crash anim here
	$AudioVroom.stop()
	$AudioBoom.play()
	await get_tree().create_timer(0.3).timeout
	update_pos_from_grid()
	end_turn()

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


# collision with terrain TileMap
func _on_area_2d_body_entered(body):
	print('entered body %s' % [body])
#	return
	crash()

# collision with area2d: another car or the finish line
func _on_area_2d_area_entered(area):
	print('%s area entered: %s, ismyturn: %s, ismoving: %s' % [name, area.get_parent().name, is_my_turn, is_moving])
	if area.get_parent() is FinishLine: finish_enter()
	elif area.has_meta("collision"): crash()
	elif is_my_turn and is_moving and area.get_parent() is Car: crash()

func _on_area_2d_area_exited(area):
	if area.get_parent() is FinishLine: finish_exit()
