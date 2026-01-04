extends Node

var gravity_mage
var shotgun_mage
var ninja_mage

var players = []

func _process(delta): 
	if gravity_mage and gravity_mage not in players: # this is a  terrible way of implementing but I got nothing better rn
		players.append(gravity_mage)
	if shotgun_mage and shotgun_mage not in players:
		players.append(shotgun_mage)
	if ninja_mage and ninja_mage not in players:
		players.append(ninja_mage)
