extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if the player steps on the spike
		body.die()  # Calls the player's death function
