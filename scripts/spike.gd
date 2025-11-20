extends Area2D

signal player_died  # Signal to restart level

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not body.is_dead:
		print("Player touched spike!")
		body.die()
		
