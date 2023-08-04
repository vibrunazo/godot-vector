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
	draw_line(Vector2.ZERO, Vector2(200, 0), Color.RED, 8)
	var arrow_head = [Vector2(220, 0), Vector2(180, 20), Vector2(180, -20)]
	draw_colored_polygon(arrow_head, Color.RED)

func _input(event):
	if event.is_action("ui_right") and not event.is_pressed():
		input_move(Vector2(1, 0))
	if event.is_action("ui_up") and not event.is_pressed():
		input_move(Vector2(0, -1))
	if event.is_action("ui_left") and not event.is_pressed():
		input_move(Vector2(-1, 0))
	if event.is_action("ui_down") and not event.is_pressed():
		input_move(Vector2(0, 1))

func input_move(v: Vector2):
	next_move = v
	move()

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
