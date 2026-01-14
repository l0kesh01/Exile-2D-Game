extends CharacterBody2D
signal health_changed(current, max)
signal boss_defeated

@export var SPEED: float = 50.0
@export var ATTACK_RANGE: float = 50.0
@export var ATTACK_COOLDOWN: float = 1.5
@export var MAX_HEALTH: int = 5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_hitbox: Area2D = $AttackHitbox
var has_hit_this_attack := false
var current_health: int
var player: Node2D = null
var attack_timer := 0.0
var is_dead := false

func _ready():
	current_health = MAX_HEALTH
	emit_signal("health_changed", current_health, MAX_HEALTH)
	# Keep this since you said detection works and signals can desync late-game
	detection_area.monitoring = true
	detection_area.monitorable = true

	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	# Ensure hitbox starts OFF
	attack_hitbox.monitoring = false

func _physics_process(delta):
	if is_dead:
		return

	attack_timer -= delta

	if player:
		var to_player = player.global_position - global_position
		var horizontal_distance = abs(to_player.x)

		# Always face player when engaged
		sprite.flip_h = to_player.x < 0
		_update_detection_position()
		_update_attack_hitbox_position()

		if horizontal_distance > ATTACK_RANGE:
			# Chase
			velocity = to_player.normalized() * SPEED
			sprite.play("DL1-WALK")
		else:
			# Attack
			velocity = Vector2.ZERO
			sprite.play("DL1-A1")

			if attack_timer <= 0:
				_do_attack()
				attack_timer = ATTACK_COOLDOWN
	else:
		velocity = Vector2.ZERO
		sprite.play("DL1-IDLE")

	move_and_slide()

# Option A: instant hitbox toggle (single-frame)
func _do_attack() -> void:
	has_hit_this_attack = false
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.25).timeout
	attack_hitbox.monitoring = false

func _update_detection_position() -> void:
	# Keep DetectionArea in front
	if sprite.flip_h:
		detection_area.position.x = -abs(detection_area.position.x)
	else:
		detection_area.position.x = abs(detection_area.position.x)

func _update_attack_hitbox_position() -> void:
	# Keep AttackHitbox in front too (important!)
	if sprite.flip_h:
		attack_hitbox.position.x = -abs(attack_hitbox.position.x)
	else:
		attack_hitbox.position.x = abs(attack_hitbox.position.x)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		attack_timer = 0.0

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_attack_hitbox_body_entered(body):
	if has_hit_this_attack:
		return

	if body.is_in_group("player"):
		body.take_damage(2)
		has_hit_this_attack = true

func take_damage(amount: int):
	print("TAKE DAMAGE CALLED:", amount)
	if is_dead:
		return

	current_health -= amount
	emit_signal("health_changed", current_health, MAX_HEALTH)

	if current_health <= 0:
		die()
	else:
		# Optional: quick hurt feedback if you want
		# sprite.play("DL1-HURT")
		pass

func die():
	if is_dead:
		return

	is_dead = true
	sprite.play("DL1-DEATH")

	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)

	emit_signal("boss_defeated")

	if not sprite.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished():
	queue_free()
	
