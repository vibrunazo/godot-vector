extends Camera2D

class_name RaceCam

@export var car: Car

signal finished_pos_tween

var zoom_target: float = 1.0
var cam_modified: bool = false
var zoom_tween: Tween
var pos_tween: Tween
var is_following: bool = true
var is_focused: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func follow():
#	if !car or not is_following: return
#	position = car.position
	

func change_car(newcar: Car):
	car = newcar
	is_focused = false
	if is_following: start_pos_tween()
#	if cam_modified: return
#	await get_tree().create_timer(1.0).timeout
#	if car.is_moving or cam_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(2, 2), 0.3)

func start_pos_tween():
	if pos_tween: pos_tween.stop()
	pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	await pos_tween.tween_property(self, "position", car.position, 0.4).finished
	finished_pos_tween.emit()

func on_car_started_move():
	focus_out()
	if cam_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(1, 1), 0.3)

func focus_player():
	var value = 1.0
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
	zoom_tween.tween_property(self, "zoom", Vector2(0.5, 0.5), 0.5)
	
func zoom_in():
	cam_modified = true
	is_focused = false
	zoom += Vector2(0.2, 0.2)

func zoom_out():
	cam_modified = true
	is_focused = false
	zoom -= Vector2(0.2, 0.2)

func zoom_reset():
	is_following = true
	is_focused = false
	start_pos_tween()
	cam_modified = false
	zoom = Vector2(0.5, 0.5)

func pan(v: Vector2):
	is_following = false
	position += v
