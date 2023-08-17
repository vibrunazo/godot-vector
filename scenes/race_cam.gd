extends Camera2D

class_name RaceCam

@export var car: Car

var zoom_target: float = 1.0
var zoom_modified: bool = false
var zoom_tween: Tween
var pos_tween: Tween
var is_following: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	follow()

func follow():
	if !car or not is_following: return
#	position = car.position
	

func change_car(newcar: Car):
	car = newcar
	if is_following: start_pos_tween()
	if zoom_modified: return
	await get_tree().create_timer(1.0).timeout
	if car.is_moving or zoom_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(2, 2), 0.3)

func start_pos_tween():
	if pos_tween: pos_tween.stop()
	pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	pos_tween.tween_property(self, "position", car.position, 0.5)

func on_car_started_move():
	if zoom_modified: return
#	zoom_tween = create_tween()
#	zoom_tween.tween_property(self, "zoom", Vector2(1, 1), 0.3)

func zoom_in():
	zoom_modified = true
	zoom += Vector2(0.2, 0.2)

func zoom_out():
	zoom_modified = true
	zoom -= Vector2(0.2, 0.2)

func zoom_reset():
	is_following = true
	start_pos_tween()
	zoom_modified = false
	zoom = Vector2(1, 1)

func pan(v: Vector2):
	is_following = false
	position += v
