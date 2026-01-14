extends CanvasLayer

@onready var player_bar: ProgressBar = $PlayerHealthBar
@onready var health_text: Label = $PlayerHealthBar/HealthText
@onready var boss_bar = get_node_or_null("BossHealthBar")

var current_boss = null

func _ready():
	boss_bar.visible = false

	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)

		var data = player.get_health_data()
		_on_player_health_changed(data.current, data.max)

func connect_boss(boss):
	if boss_bar == null:
		return
	if boss == current_boss:
		return   # already connected

	# disconnect old boss
	if current_boss and current_boss.is_connected("health_changed", _on_boss_health_changed):
		current_boss.disconnect("health_changed", _on_boss_health_changed)

	current_boss = boss
	boss_bar.visible = true

	boss.health_changed.connect(_on_boss_health_changed)
	if boss.has_signal("boss_defeated"):
		boss.boss_defeated.connect(_on_boss_defeated)

func _on_boss_health_changed(current, max):
	print("BOSS HP:", current, "/", max)
	boss_bar.max_value = max
	boss_bar.value = current

func _on_boss_defeated():
	boss_bar.visible = false
	current_boss = null

func _on_player_health_changed(current, max):
	player_bar.max_value = max
	player_bar.value = current
	health_text.text = str(current) + " / " + str(max)

func reset_boss():
	if current_boss:
		if current_boss.is_connected("health_changed", _on_boss_health_changed):
			current_boss.disconnect("health_changed", _on_boss_health_changed)
		if current_boss.is_connected("boss_defeated", _on_boss_defeated):
			current_boss.disconnect("boss_defeated", _on_boss_defeated)

	current_boss = null
	if boss_bar:
		boss_bar.visible = false

func show_level_complete():
	$WinScreen.visible = true
