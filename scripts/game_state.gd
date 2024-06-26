## GameState autoload contains data about current game state that is accessed by various game objects
extends Node

var cars: Array[Car]

var is_ready: bool = true
## if true, one of the cars have already won and the game has sped up
var is_sped_up: bool = false

## returns whether this car is ahead of a player controlled car
## used by the AI to know whether it should take it easy on the noob
func is_car_ahead_of_player(ai_car: Car) -> bool:
	for car in cars:
		if car.control_type != car.Controller.AI and car.race_pos > ai_car.race_pos:
			return true
	return false
