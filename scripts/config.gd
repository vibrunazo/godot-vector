## Config autoload holds global variables the user can change 
## and that will be saved and loaded from disk
extends Node

## Whether cam should center on cars at the start of each turn
var follow_mode: FOLLOW = FOLLOW.NONE
## If cam should auto focus on local controlled cars at the start of each turn. 
## When true it is also required to have focus to be able to click to input
var auto_focus: bool = false

enum FOLLOW {
	NONE, # cam won't follow any car
	LOCAL, # cam follow local players only
	ALL, # cam follows all cars
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

