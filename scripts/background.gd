extends Node2D

@onready var camera = get_tree().get_first_node_in_group("main_camera")

func _process(delta):
	if camera:
		global_position = camera.global_position
