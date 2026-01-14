extends Area2D

func _on_detection_area_body_entered(body: Node) -> void:
	print("Entered:", body.name)
	if body.is_in_group("player"):
		print("Player detected")
		get_parent().target = body


func _on_detection_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if get_parent().target == body:
			get_parent().target = null
