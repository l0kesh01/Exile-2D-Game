extends Node2D

@export var level_scenes := [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
]

@onready var player := $Player
@onready var current_level_holder := $CurrentLevel

var current_level: Node = null
var current_level_index := 0

func _ready():
	add_to_group("game_root")
	load_level(0)

func load_level(index: int) -> void:
	# Remove old level
	if current_level:
		current_level.queue_free()

	current_level_index = index

	# Instance new level
	current_level = load(level_scenes[current_level_index]).instantiate()
	current_level_holder.add_child(current_level)

	# Reset player FIRST
	if player.has_method("reset_player"):
		player.reset_player()

	var spawn := current_level.get_node_or_null("SpawnPoint")
	if spawn:
		player.global_position = spawn.global_position

	# Wait so enemies/boss are fully in tree
	await get_tree().process_frame
	await get_tree().process_frame

	# Find boss belonging to THIS level only
	var boss = null
	for node in get_tree().get_nodes_in_group("boss"):
		if node.is_inside_tree() and node.get_parent() == current_level:
			boss = node
			break

	if boss:
		# Connect HUD
		$HUD.connect_boss(boss)

		# Let boss reset internal state if needed
		if boss.has_method("on_level_loaded"):
			boss.on_level_loaded()

		# 🔥 FINAL LEVEL → go to WinScreen on boss death
		if current_level_index == level_scenes.size() - 1:
			if not boss.is_connected("boss_defeated", Callable(self, "_on_final_boss_defeated")):
				boss.boss_defeated.connect(_on_final_boss_defeated)

func next_level() -> void:
	if current_level_index + 1 < level_scenes.size():
		load_level(current_level_index + 1)
	else:
		get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")

func reload_current_level():
	$HUD.reset_boss()
	load_level(current_level_index)

func _on_final_boss_defeated():
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
