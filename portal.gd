extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	monitoring = false
	visible = false
	call_deferred("_connect_to_boss")
	var boss = get_tree().get_first_node_in_group("boss")
	print("PORTAL READY. FOUND BOSS =", boss)

	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
	else:
		print("PORTAL: NO BOSS FOUND -> not connected")

func _on_boss_defeated():
	visible = true
	monitoring = true
	sprite.play()

func _connect_to_boss():
	var boss = get_tree().get_first_node_in_group("boss")
	print("PORTAL CONNECT. FOUND BOSS =", boss)
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
		
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		var root = get_tree().get_first_node_in_group("game_root")
		if root:
			root.next_level()

func _level_complete():
	print("LEVEL COMPLETE")

	# Option A: show HUD message
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_level_complete()

	# Option B (later): load next level
	# get_tree().change_scene_to_file("res://levels/Level2.tscn")
