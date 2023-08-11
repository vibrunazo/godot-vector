@tool

extends Control

class_name Grid


@export var cell_size := 16
## width in number of cells
@export var width := 200
## height in number of cells
@export var height := 100
var gcolor := Color(0.25, 0.2, 0.3, 0.3)
var pcolor := Color(0.1, 0.1, 0.35, 0.6)
var dcolor := Color(0.05, 0.05, 0.2, 0.6)
var gwidth := 1
var pwidth := 1
var dwidth := 2
var daa := false
var primary_every := 5
var double_every := 10

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		dwidth = 4
		daa = true

func _draw():
	print('draw grid here')
	draw_grid()

func draw_grid():
	if not Engine.is_editor_hint():
		for n in range(1, width + 1):
			draw_col(n, 1)
		for n in range(1, height + 1):
			draw_row(n, 1)
		for n in range(1, 1 + float(width)/primary_every):
			draw_col(n, primary_every)
		for n in range(1, 1 + float(height)/primary_every):
			draw_row(n, primary_every)
	for n in range(0, 1 + float(width)/double_every):
		draw_col(n, double_every)
	for n in range(0, 1 + float(height)/double_every):
		draw_row(n, double_every)

func draw_row(n: int, e: int):
	var from := Vector2(0, n * cell_size * e)
	var to:= Vector2(width * cell_size, n * cell_size * e)
	draw_segment(from, to, e, n)

func draw_col(n: int, e: int):
	var from := Vector2(n * cell_size * e, 0)
	var to:= Vector2(n * cell_size * e, height * cell_size)
	draw_segment(from, to, e, n)

func draw_segment(from, to, e, n):
	if e == 1 and not (n % primary_every == 0):
		draw_line(from, to, gcolor, gwidth)
	elif e == primary_every and not (n % (double_every / primary_every) == 0):
		draw_line(from, to, pcolor, pwidth)
	elif e == double_every:
		draw_line(from, to, dcolor, dwidth, daa)
#	if n % double_every == 0:
#		draw_line(from, to, dcolor, 2)
#	elif n % primary_every == 0:
#		draw_line(from, to, pcolor, 1)
#	else:
#		draw_line(from, to, gcolor, 1)
