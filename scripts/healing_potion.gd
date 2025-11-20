extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("heal_full"):
			body.heal_full()
		queue_free()
