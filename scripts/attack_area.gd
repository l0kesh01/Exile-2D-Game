extends Area2D

@onready var player = get_parent()

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if not player.is_attacking:
		return  # Only detect hits during attack animation

	if body.is_in_group("enemies") and body.has_method("take_damage"):
		print("Player hit enemy: ", body.name)
		body.take_damage(player.attack_damage)
