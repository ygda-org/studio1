extends Node

var gravity_mage
var shotgun_mage
var ninja_mage

var players = []

func _process(_delta): 
	if gravity_mage and gravity_mage not in players: # this is a  terrible way of implementing but I got nothing better rn
		players.append(gravity_mage)
	if shotgun_mage and shotgun_mage not in players:
		players.append(shotgun_mage)
	if ninja_mage and ninja_mage not in players:
		players.append(ninja_mage)

@rpc("any_peer")
func ninja_swap(swapped):
	var ninja = ninja_mage.get_parnet().get_node("ninja_swappable") # two guys are the two swappables nodes
	ninja.ninja_swap.rpc(swapped)
	swapped.ninja_swap.rpc(ninja)


func log(message: String) -> void:
	print_rich("[color=white][LOG][/color] " + message)

func critical(message: String) -> void:
	print_rich("[color=yellow][CRITICAL][/color] " + message)

func error(message: String) -> void:
	print_rich("[color=red][ERROR][/color] " + message)
