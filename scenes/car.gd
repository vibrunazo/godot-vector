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

# Called when the node enters the scene tree for the first time.
func _ready():
	if grid:
		cell_size = grid.cell_size
	update_grid_from_pos()
	update_pos_from_grid()
	ini_grid_pos = grid_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	draw_arrows()

func draw_arrows():
	var to = grid2pix(svector)
	var p := grid2pix(ini_grid_pos) - global_position
	var ac := Color(0.9, 0.2, 0.2)
	var oc := Color(0.2, 0.05, 0.05)
	var max : = 40
	var size = float(history.size())
	var i = 0.0
	# TODO count backwards to avoid wasting loops on undrew old vectors
	for v in history:
		v = grid2pix(v)
		var k = (1 - (size - i) / max) * 0.75
		var ok = k * 0.8
		var h = 10
		var d = 3
		var c := ac * Color(ac.r, ac.g, ac.b, k)
		if i == size - 1: 
			k = 1
			ok = 1
			h = 14
			d = 6
		else:
			c.s = c.s * (k + 0.1)
			c.v = c.v * (k - 0)
		if k > 0:
			draw_arrow(p, p + v, c, oc * ok, h, d)
		p += v
		i += 1.0
#	draw_arrow(Vector2.ZERO, to, ac * 0.5, oc * 0.5, 0)
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
	queue_redraw()

func move():
	svector += next_move
	grid_pos += svector
	history.append(svector)
	update_pos_from_grid()

func update_pos_from_grid():
	position = grid2pix(grid_pos)

func update_grid_from_pos():
	grid_pos = pix2grid(position)

func grid2pix(g: Vector2) -> Vector2:
	return g * cell_size

func pix2grid(p: Vector2) -> Vector2:
	return Vector2(floor(p.x / cell_size), floor(p.x / cell_size))
