extends Node2D

class_name Car

signal started_move
signal turn_end
signal registered

@export var grid: Grid
@export var color: Color = Color(0.9, 0.2, 0.2)
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
	tilemap = $"../../TileMap"
	var mouse := tilemap.get_local_mouse_position()
	var local_pos := global_position - tilemap.global_position
	var cell = tilemap.local_to_map(local_pos)
	var data := tilemap.get_cell_tile_data(0, cell)
	print('cell: %s terrain: %s' % [cell, data.terrain])
	return data.terrain
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
	
func _input(event):
	return
	if is_moving: return
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
		

func input_move(v: Vector2) -> bool:
	if is_moving: return false
	if not is_my_turn: return false
	next_move = v
	move()
	return true

func move():
	svector += next_move
	grid_pos += svector
	car_history.show_target_at(grid_pos)
	car_history.hide_dots()
	move_to_cur_grid()
#	await get_tree().create_timer(1.0).timeout
	history.append(svector)
	started_move.emit()
#	queue_redraw()

func move_to_cur_grid():
	is_moving = true
	%SelectionSprite.visible = false
	var tween = create_tween()
	tween.tween_property(self, "position", grid2pix(grid_pos), 1)
	tween.tween_callback(move_end)

func update_pos_from_grid():
	position = grid2pix(grid_pos)
#	car_history.update_vectors()

func move_end():
	is_moving = false
#	car_history.update_vectors()
	apply_terrain_mod()
	update_draw()
	is_my_turn = false
	turn_end.emit()

func update_grid_from_pos():
	grid_pos = pix2grid(global_position)

#TODO should be a global or something idk
func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2:
	return Vector2(floor(p.x / cell_size), floor(p.y / cell_size))
