extends Area2D

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		print("Player detected!")
		get_parent().player = body

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		if get_parent().player == body:
			print("Player exited detection!")
			get_parent().player = null
