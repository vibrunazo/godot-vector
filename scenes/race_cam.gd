extends Camera2D

class_name RaceCam

@export var car: Car
@export var ZOOM_RESET: float = 0.5
@export var ZOOM_FOCUS: float = 1.0


signal finished_pos_tween

var zoom_target: float = 1.0
var cam_modified: bool = false
var zoom_tween: Tween
var pos_tween: Tween
var is_focused: bool = false


func change_car(newcar: Car):
	car = newcar
	is_focused = false
	var is_following := (Config.follow_mode == Config.FOLLOW.ALL) \
	or (Config.follow_mode == Config.FOLLOW.LOCAL and car.control_type == car.Controller.LOCAL)
	if is_following:
		start_pos_tween()
	if car.control_type == car.Controller.LOCAL and Config.auto_focus:
		if is_following:
			await finished_pos_tween
		focus_player()
#	if cam_modified: return
#	await get_tree().create_timer(1.0).timeout
#	if car.is_moving or cam_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(2, 2), 0.3)

## Tweens cam position to center on the current turn's car
func start_pos_tween():
	if pos_tween: pos_tween.stop()
	pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	await pos_tween.tween_property(self, "position", car.position, 0.4).finished
	finished_pos_tween.emit()

## Called by RaceGame when player makes an input and car starts moving
func on_car_started_move():
	if Config.follow_mode == Config.FOLLOW.NONE: return
	focus_out()
	#if cam_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(1, 1), 0.3)

## Focus camera on player car by zooming in to appropriate level to receive click input
## A car can only receive click inputs if it's focused, else it will force focus when clicked
func focus_player():
	var value = ZOOM_FOCUS
	cam_modified = false
	zoom_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	start_pos_tween()
	await zoom_tween.tween_property(self, "zoom", Vector2(value, value), 0.5).finished
	if cam_modified == false:
		is_focused = true
#	zoom = Vector2(value, value)

func focus_out():
	is_focused = false
	zoom_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(self, "zoom", Vector2(ZOOM_RESET, ZOOM_RESET), 0.5)
	
func zoom_in():
	cam_modified = true
	is_focused = false
	var z: = minf(zoom.x + 0.05, 1)
	zoom = Vector2(z, z)

func zoom_out():
	cam_modified = true
	is_focused = false
	var z: = maxf(zoom.x - 0.05, 0.2)
	zoom = Vector2(z, z)

func zoom_reset():
	is_focused = false
	cam_modified = false
	start_pos_tween()
	zoom = Vector2(ZOOM_RESET, ZOOM_RESET)

func pan(v: Vector2):
	position += v
