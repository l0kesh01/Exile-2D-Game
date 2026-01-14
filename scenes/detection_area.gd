extends Area2D

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		print("Player detected!")
		get_parent().player = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		if get_parent().player == body:
			print("Player exited detection!")
			get_parent().player = null
