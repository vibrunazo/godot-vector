extends Control

class_name Grid

var cell_size := 14
var gcolor := Color(0.25, 0.2, 0.3)
var pcolor := Color(0.1, 0.1, 0.35)
var dcolor := Color(0.05, 0.05, 0.2)
var primary_every := 5
var double_every := 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	print('draw grid here')
	draw_grid()

func draw_grid():
	for n in range(1, 200):
		draw_row(n, 1)
		draw_col(n, 1)
	for n in range(1, 200.0/primary_every):
		draw_row(n, primary_every)
		draw_col(n, primary_every)
	for n in range(0, 200.0/double_every):
		draw_row(n, double_every)
		draw_col(n, double_every)

func draw_row(n: int, e: int):
	var from := Vector2(0, n * cell_size * e)
	var to:= Vector2(2000, n * cell_size * e)
	draw_segment(from, to, e, n)

func draw_col(n: int, e: int):
	var from := Vector2(n * cell_size * e, 0)
	var to:= Vector2(n * cell_size * e, 2000)
	draw_segment(from, to, e, n)

func draw_segment(from, to, e, n):
	if e == 1 and not (n % primary_every == 0):
		draw_line(from, to, gcolor, 1)
	elif e == primary_every and not (n % (double_every / primary_every) == 0):
		draw_line(from, to, pcolor, 1)
	elif e == double_every:
		draw_line(from, to, dcolor, 2)
#	if n % double_every == 0:
#		draw_line(from, to, dcolor, 2)
#	elif n % primary_every == 0:
#		draw_line(from, to, pcolor, 1)
#	else:
#		draw_line(from, to, gcolor, 1)