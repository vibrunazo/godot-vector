extends Node2D

var grid_pos := Vector2(0, 0)
var cell_size := 16
var next_move := Vector2(0, 0)
## current speed vector
var svector := Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_grid_from_pos()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	var to = grid2pix(svector)
	draw_arrow(Vector2.ZERO, to)

func draw_arrow(from: Vector2, to: Vector2):
	var head_size = 16
	var head_angle = 0.4 #rad
	var acolor = Color(0.9, 0.1, 0.1)
	var ocolor = Color(0.2, 0.05, 0.05)
	# full vector
	var v = to - from
	# remove the tip of the full vector by this much
	var tip = v.normalized() * (head_size - 2)
	var tip2 = v.normalized() * (head_size - 9)
	# the final vector to draw with the tip removed
	var line = v - tip
	var line2 = v - tip2
	var h1 = v
	h1 = - h1.normalized().rotated(head_angle) * head_size
	var e1 = to + h1
#	draw_line(to, e1, Color.PURPLE, 3)
	var h2 = v
	h2 = - h2.normalized().rotated(-head_angle) * head_size
	var e2 = to + h2
#	draw_line(to, e2, Color.PURPLE, 3)
	var arrow_head = [to, e1, e2, to]
	draw_colored_polygon(arrow_head, acolor)
	draw_polyline(arrow_head, ocolor, 0.8, true)
	draw_line(from, line, ocolor, 5, true)
	draw_line(from, line2, acolor, 2, true)

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
	update_pos_from_grid()

func update_pos_from_grid():
	position = grid2pix(grid_pos)

func update_grid_from_pos():
	grid_pos = pix2grid(position)

func grid2pix(g: Vector2):
	return g * cell_size

func pix2grid(p: Vector2):
	return p / cell_size
