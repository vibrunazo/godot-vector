extends Control

var cell_size := 16
var gcolor := Color(0.25, 0.2, 0.3)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	print('draw grid here')
	draw_grid()

func draw_grid():
	for n in range(1, 100):
		draw_row(n)
		draw_col(n)

func draw_row(n: int):
	var from := Vector2(0, n * cell_size)
	var to:= Vector2(1600, n * cell_size)
	draw_line(from, to, gcolor, 1)

func draw_col(n: int):
	var from := Vector2(n * cell_size, 0)
	var to:= Vector2(n * cell_size, 1600)
	draw_line(from, to, gcolor, 1)
