extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.die()  # call your custom player death function
