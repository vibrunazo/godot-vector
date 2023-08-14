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
		new_label.text = '%s: 0' % [car.name]
		# LabelSettings needs to be duplicated else they all share same color
		var settings: LabelSettings = new_label.label_settings.duplicate()
		new_label.label_settings = settings
		settings.font_color = car.color
	label.queue_free()

func on_ui_update_requested():
	print('update ui')
	for i in game.cars.size():
		var car: Car = game.cars[i]
		if not car: continue
		var label: Label = score_labels[i]
		label.text = '%s: %d' % [car.name, max(car.laps, 0)]

func _on_button_zp_pressed():
	if not cam: return
	cam.zoom_in()

func _on_button_zm_pressed():
	if not cam: return
	cam.zoom_out()


func _on_button_center_pressed():
	if not cam: return
	cam.zoom_reset()
