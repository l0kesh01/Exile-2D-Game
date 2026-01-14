extends CharacterBody2D

signal boss_defeated
signal health_changed(current, max)

# --------------------
# CONFIG
# --------------------
@export var SPEED := 60.0
@export var ATTACK_RANGE := 55.0
@export var ATTACK_COOLDOWN := 1.3
@export var MAX_HEALTH := 10

@export var FREEZE_DAMAGE := 1.5
@export var FIRE_DAMAGE := 3.0

# hover
@export var glide_distance := 120.0

# attack animation lengths (seconds)
@export var ATTACK1_TIME := 1.0
@export var ATTACK2_TIME := 1.0

# If your art faces LEFT by default, keep -1
const ASSET_FACING := -1

# --------------------
# NODES
# --------------------
@onready var visuals: Node2D = $Visuals
@onready var sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

# --------------------
# STATE
# --------------------
var current_health: int
var player: Node2D = null
var is_active := false
var is_dead := false
var is_attacking := false

var attack_timer := 0.0
var attack_anim_timer := 0.0

# attack sequence: 3x freeze then 1x fire
var freeze_count := 0

# movement
var glide_dir := 1
var start_x := 0.0

# facing: 1 = right, -1 = left
var facing_dir := 1

# --------------------
# LIFE CYCLE
# --------------------
func _ready():
	current_health = MAX_HEALTH
	emit_signal("health_changed", current_health, MAX_HEALTH)

	start_x = global_position.x
	sprite.play("L3_Idle")
	_apply_facing()

	# Safety: ensure signals are connected even if you forgot editor connections
	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	# Safety: if player already exists, grab it
	_ensure_player()

func _physics_process(delta):
	if is_dead:
		return

	# 🔥 CRITICAL: reacquire player if needed (fixes respawn/transition edge cases)
	_ensure_player()

	# handle attack animation lock
	if is_attacking:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0.0:
			is_attacking = false
			sprite.play("L3_Idle")

	# movement (only when not attacking)
	if not is_attacking:
		_hover_move()

	# combat decision (do NOT rely only on detection events)
	if player and is_instance_valid(player):
		_handle_combat(delta)

	move_and_slide()

	# bounce off walls during hover so it never gets stuck
	if not is_attacking and is_on_wall():
		_bounce_from_wall()

# --------------------
# PLAYER ACQUIRE (THE FIX)
# --------------------
func _ensure_player():
	# If detection failed due to overlap/order, recover automatically
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

# --------------------
# MOVEMENT
# --------------------
func _hover_move():
	velocity.x = glide_dir * SPEED

	# Face the direction we are moving (ONLY here, ONLY by visuals scale)
	facing_dir = glide_dir
	_apply_facing()

	# simple back-and-forth based on distance traveled
	if abs(global_position.x - start_x) >= glide_distance:
		glide_dir *= -1
		start_x = global_position.x

func _bounce_from_wall():
	glide_dir *= -1
	start_x = global_position.x

	# reapply instantly so it keeps moving next frame
	velocity.x = glide_dir * SPEED
	facing_dir = glide_dir
	_apply_facing()

func _apply_facing():
	# Flip everything under Visuals, never the sprite itself
	visuals.scale.x = abs(visuals.scale.x) * facing_dir * ASSET_FACING

# --------------------
# COMBAT
# --------------------
func _handle_combat(delta):
	if is_attacking:
		return

	var dx = player.global_position.x - global_position.x
	var dist = abs(dx)

	# only attack when close enough
	if dist > ATTACK_RANGE:
		return

	attack_timer -= delta
	if attack_timer <= 0.0:
		_perform_attack(dx)
		attack_timer = ATTACK_COOLDOWN

func _perform_attack(dx_to_player: float):
	is_attacking = true

	# lock facing toward player once per attack
	facing_dir = -1 if dx_to_player < 0 else 1
	_apply_facing()

	if freeze_count < 3:
		sprite.play("L3_Attack 1")
		_deal_damage(FREEZE_DAMAGE)
		freeze_count += 1
		attack_anim_timer = ATTACK1_TIME
	else:
		sprite.play("L3_Attack 2")
		_deal_damage(FIRE_DAMAGE)
		freeze_count = 0
		attack_anim_timer = ATTACK2_TIME

func _deal_damage(amount: float):
	if player and is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(amount)

# --------------------
# DETECTION (optional now, not required for correctness)
# --------------------
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		attack_timer = 0.0

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

# --------------------
# HEALTH / DEATH
# --------------------
func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	emit_signal("health_changed", current_health, MAX_HEALTH)

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false

	velocity = Vector2.ZERO
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)

	sprite.play("L3_death")

	if not sprite.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished():
	emit_signal("boss_defeated")
	queue_free()

func on_level_loaded():
	# reset AI state (optional)
	player = null
	is_attacking = false
	attack_timer = 0.0
	_ensure_player()
