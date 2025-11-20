extends Node2D

@onready var level_container = $LevelContainer
@onready var player = $Player

# Path to the current level scene
var current_level_scene: PackedScene = preload("res://scenes/level_1.tscn")

func _ready():
	load_level(current_level_scene)

func load_level(scene: PackedScene):
	# Clear old level if exists
	for child in level_container.get_children():
		child.queue_free()

	# Instance and add the new level
	var level_instance = scene.instantiate()
	level_container.add_child(level_instance)

	# Optional: reposition player to level's spawn point if defined
	var spawn = level_instance.get_node_or_null("SpawnPoint")
	if spawn:
		player.global_position = spawn.global_position

	print("Loaded level:", scene.resource_path)
