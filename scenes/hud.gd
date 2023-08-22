extends Control

@export var game: RaceGame
@export var cam: RaceCam
var score_labels: Array[Label]

# Called when the node enters the scene tree for the first time.
func _ready():
	register_signals()
	build_score_labels()

func register_signals():
	if game:
		game.update_ui.connect(on_ui_update_requested)

func build_score_labels():
	var label: Label = $Score/VBox/Label
	for i in game.cars.size():
		var car: Car = game.cars[i]
		if not car: continue
		var new_label: Label = label.duplicate()
		score_labels.append(new_label)
		$Score/VBox.add_child(new_label)
		# LabelSettings needs to be duplicated else they all share same color
		var settings: LabelSettings = new_label.label_settings.duplicate()
		new_label.label_settings = settings
		settings.font_color = car.color
		update_car_score(i)
	label.queue_free()

func on_ui_update_requested():
	for i in game.cars.size():
		var car: Car = game.cars[i]
		if not car: continue
		update_car_score(i)

func update_car_score(i: int):
	var label: Label = score_labels[i]
	var car: Car = game.cars[i]
	var pos: int = game.find_car_position(car)
#	var d = game.track.calculate_car_distance_left(car)
	var e = ''
	if car.ai: e = ' e%d' % round(car.ai.effective_difficulty)
	label.text = '%d. %s %s: %d%s' % [pos, car.name, car.svector, max(car.laps, 0), e]
	label.get_parent().move_child(label, car.race_pos - 1)

func _on_button_zp_pressed():
	if not cam: return
	cam.zoom_in()

func _on_button_zm_pressed():
	if not cam: return
	cam.zoom_out()

func _on_button_center_pressed():
	if not cam: return
	cam.zoom_reset()

func _on_button_right_pressed():
	var cell_size := game.grid.cell_size
	cam.pan(Vector2(cell_size * 5, 0))

func _on_button_left_pressed():
	var cell_size := game.grid.cell_size
	cam.pan(Vector2(-cell_size * 5, 0))

func _on_button_up_pressed():
	var cell_size := game.grid.cell_size
	cam.pan(Vector2(0, -cell_size * 5))

func _on_button_down_pressed():
	var cell_size := game.grid.cell_size
	cam.pan(Vector2(0, cell_size * 5))
