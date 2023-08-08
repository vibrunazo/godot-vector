extends Node2D

class_name Car

@export var grid: Grid
var grid_pos := Vector2(0, 0)
var ini_grid_pos := Vector2(0, 0)
var cell_size := 16
var next_move := Vector2(0, 0)
## current speed vector
var svector := Vector2(0, 0)
var history: Array[Vector2]
var car_history: CarHistory
var is_moving: = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if grid:
		cell_size = grid.cell_size
	update_grid_from_pos()
	ini_grid_pos = grid_pos
	register_car_history()
	update_pos_from_grid()

func register_car_history():
	car_history = %CarHistory
	car_history.car = self
	var parent = get_parent()
	var vecs = parent.get_node("%Vectors")
	if vecs: parent = vecs
	car_history.reparent.call_deferred(parent, false)
	car_history.build_dots()
#	car_history.update_vectors()

func update_draw():
	if car_history:
		car_history.update_vectors()
		car_history.show_dots_at(grid_pos + svector)
#	queue_redraw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	if is_moving:
#		queue_redraw()
	pass
	
func _draw():
	print('drew')
#	draw_arrows()
	if not is_moving:
		var to = grid2pix(svector)
		var ac := Color(0.9, 0.2, 0.2)
		var oc := Color(0.2, 0.05, 0.05)
		draw_dots(to, ac * 0.7, oc * 0.7)

func draw_arrow(from: Vector2, to: Vector2, c: Color, oc: Color, h: float, d: float = 5):
	var head_size = h
	var head_angle = 0.5 #rad
	var acolor = c
	var ocolor = oc
	# full vector
	var v = to - from
	# remove the tip of the full vector by this much
	var tip = v.normalized() * (head_size - 2)
	var tip2 = v.normalized() * (head_size - 3)
	# the final vector to draw with the tip removed
#	var line = v - tip
	var line = from + v - tip# Vector2(20, 20)
	var line2 = from + v - tip2
	
	draw_dot(to, d, acolor, ocolor)
	if head_size > 0:
		var h1 = v
		h1 = - h1.normalized().rotated(head_angle) * head_size
		var e1 = to + h1
		var h2 = v
		h2 = - h2.normalized().rotated(-head_angle) * head_size
		var e2 = to + h2
		var arrow_head = [to, e1, e2, to]
		draw_colored_polygon(arrow_head, acolor)
		draw_polyline(arrow_head, ocolor, 0.8, true)
	draw_line(from, line, ocolor, 3, true)
	draw_line(from, line2, acolor, 1, true)
	draw_dot(from, d, acolor, ocolor)

func draw_dot(p: Vector2, size: float, acolor: Color, ocolor: Color):
	draw_circle(p, size, ocolor)
	draw_circle(p, size - 2, acolor)

func draw_dots(p: Vector2, ac, oc):
	draw_dot(p, 5, ac * 0.7, oc * 0.7)
	var dirs = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
	for dir in dirs:
		draw_dot(Vector2(p.x + cell_size * dir[0], p.y + cell_size * dir[1]), 3, ac * 0.7, oc * 0.7)

func _input(event):
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
		

func input_move(v: Vector2):
	next_move = v
	move()
#	await get_tree().create_timer(1.0).timeout
	

func move():
	svector += next_move
	grid_pos += svector
	car_history.show_target_at(grid_pos)
	car_history.hide_dots()
	update_pos_from_grid()
#	await get_tree().create_timer(1.0).timeout
	history.append(svector)
#	queue_redraw()

func update_pos_from_grid():
	is_moving = true
	var tween = create_tween()
	tween.tween_property(self, "position", grid2pix(grid_pos), 1)
	tween.tween_callback(move_end)
#	position = grid2pix(grid_pos)
#	car_history.update_vectors()

func move_end():
	is_moving = false
#	car_history.update_vectors()
	update_draw()

func update_grid_from_pos():
	grid_pos = pix2grid(position)

#TODO should be a global or something idk
func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2:
	return Vector2(floor(p.x / cell_size), floor(p.x / cell_size))
