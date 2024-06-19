extends Control

@onready var label: RichTextLabel = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		update_text()


func _unhandled_key_input(event):
	if event.is_action_pressed("debug"):
		visible = !visible
		
func update_text():
	label.text = 'FPS: %s' % Engine.get_frames_per_second()
