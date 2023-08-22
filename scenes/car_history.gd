extends Node2D

class_name CarHistory

var car: Car
## the very first arrow from the player is not shadow and is drawn highlighted
## the others are shadows, are drawn in a lower layer so all main arrows from
## all cars are on top of the shadows for better visibility
var is_shadow := true

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_dots()

func update_vectors():
	queue_redraw()
	
func _draw():
	if !car: return
	draw_arrows()

func draw_arrows():
#	var svector := car.svector
	var ini_grid_pos := car.ini_grid_pos
	var history := car.history
	var size = float(history.size())
	if size == 0: return
#	var to := grid2pix(svector)
	var p := grid2pix(ini_grid_pos) - global_position
	p = grid2pix(car.grid_pos) + global_position
	var ac := car.color
	var oc := Color(0.2, 0.05, 0.05)
	var maxs : = 30
#	if car.name == 'Car4':
#		print('%s drawing vectors s:%s' % [car.name, is_shadow])
	for i in range(history.size() - 1, -1, -1):
		var vector := history[i]
		var v: Vector2 = grid2pix(vector)
		var k = (1 - (size - i) / (maxs + 1)) * 0.75
		var ok = k * 0.6
		var w = 2
		var h = 20
		var d = 6
		var c := ac 
		p -= v
		if is_shadow:
			c *= Color(ac.r, ac.g, ac.b, k)
			c.a = c.a * 0.8 
#			oc.a = oc.a * 0.9
		if i == size - 1: 
			if is_shadow:
				continue
			k = 1
			ok = 1
			w = 10
			h = 48
			d = 16
		else:
			c.s = c.s * (k + 0.1)
			c.v = c.v * (k - 0)
		if k > 0:
#			if car.name == 'Car4':
#				print('%s size: %s, i: %s, v: %s' % [car.name, size, i, v])
			draw_arrow(p, p + v, c, oc * ok, w, h, d)
			if not is_shadow or size - i > maxs: break

func draw_arrow(from: Vector2, to: Vector2, c: Color, oc: Color, width: float, h: float, d: float = 5):
	var head_size = h
	var head_angle = 0.5 #rad
	var acolor = c
	var ocolor = oc
	# full vector
	var v = to - from
	# remove the tip of the full vector by this much
	var tip = v.normalized() * (head_size - 4)
	var tip2 = v.normalized() * (head_size - 6)
	# the final vector to draw with the tip removed
#	var line = v - tip
	var line = from + v - tip# Vector2(20, 20)
	var line2 = from + v - tip2
	
	draw_dot(to, d + 8, acolor * 0.6, ocolor)
	if head_size > 0:
		var h1 = v
		h1 = - h1.normalized().rotated(head_angle) * head_size
		var e1 = to + h1
		var h2 = v
		h2 = - h2.normalized().rotated(-head_angle) * head_size
		var e2 = to + h2
		var arrow_head = [to, e1, e2, to]
		draw_colored_polygon(arrow_head, acolor)
		draw_polyline(arrow_head, ocolor, 1.6, true)
	draw_line(Vector2(from.x, from.y + 2), Vector2(line.x, line.y + 2), ocolor * 0.1, width + 8, true)
	draw_line(Vector2(from.x, from.y + 2), Vector2(line.x, line.y + 2), ocolor * 0.1, width + 14, true)
	draw_line(from, line, ocolor, width + 8, true)
	draw_line(from, line2, acolor, width, true)
	draw_dot(from, d, acolor, ocolor)

## builds the dots that show possible targets for next move
## called by register_car_history on parent car
func build_dots():
	var cell_size = car.cell_size
	var dirs = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
	for dir in dirs:
		var dot := %TargetDotSprite.duplicate()
		%Dots.add_child(dot)
		dot.position.x += dir[0] * cell_size
		dot.position.y += dir[1] * cell_size
		if dir == [0, 0]:
			dot.transform = dot.transform.scaled(Vector2(1.5, 1.5))
		
func hide_dots():
#	%Dots.visible = false
	$AnimDots.play("hide_dots")

## shows the dots of possible options where the user can go
## called by the owning car when its turn begins
func show_dots():
	$AnimDots.play("show_dots")
	%Dots.visible = true

func draw_dot(p: Vector2, size: float, acolor: Color, ocolor: Color):
	draw_circle(p, size, ocolor)
	draw_circle(p, size - 4, acolor)

## shows target dot animating to highlight to the user where he's going to
## called when user just moved and car starts moving towards target
func show_target_at(p: Vector2):
	%TargetDot.visible = true
	%TargetDot.position = grid2pix(p)
	$AnimTarget.play("selected")

## hides the selected target dot
## called by the car when the move ends
func hide_target():
	%TargetDot.visible = false

## updates the position where the target dots will show up in the future
## when it's my turn
func update_dots_at(p: Vector2):
	%Dots.position = grid2pix(p)

func grid2pix(g: Vector2) -> Vector2:
	return car.grid2pix(g)
