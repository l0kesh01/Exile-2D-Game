extends CharacterBody2D

# --------------------
# CONFIG
# --------------------
@export var SPEED: float = 50.0
@export var ATTACK_RANGE: float = 50.0
@export var patrol_distance: float = 75.0
@export var ATTACK_COOLDOWN: float = 1.5
@export var max_health: int = 3

# --------------------
# NODES
# --------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

# --------------------
# STATE
# --------------------
var player: Node2D = null
var start_position: Vector2
var patrol_direction := 1
var attack_timer := 0.0

# Health
var current_health: int
var is_dead := false

# --------------------
# LIFE CYCLE
# --------------------
func _ready():
	current_health = max_health
	start_position = global_position

func _physics_process(delta):
	if is_dead:
		return

	if player:
		_handle_combat(delta)
	else:
		_patrol()

	move_and_slide()

# --------------------
# BEHAVIOR
# --------------------
func _handle_combat(delta):
	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance > ATTACK_RANGE:
		# Chase
		velocity = to_player.normalized() * SPEED
		_update_facing(velocity.x)
		sprite.play("walk")
	else:
		# Attack
		velocity = Vector2.ZERO
		sprite.play("attack")
		attack_timer -= delta

		var is_facing_player = (to_player.x < 0 and sprite.flip_h) or (to_player.x > 0 and not sprite.flip_h)

		if attack_timer <= 0 and is_facing_player:
			if player.has_method("take_damage"):
				player.take_damage(1)
			attack_timer = ATTACK_COOLDOWN

func _patrol():
	velocity.x = patrol_direction * SPEED
	_update_facing(velocity.x)
	sprite.play("walk")

	if abs(global_position.x - start_position.x) >= patrol_distance:
		patrol_direction *= -1
		start_position = global_position

func _update_facing(x_dir: float):
	if x_dir == 0:
		return

	var facing_left := x_dir < 0
	sprite.flip_h = facing_left
	detection_area.position.x = -abs(detection_area.position.x) if facing_left else abs(detection_area.position.x)

# --------------------
# DETECTION (UNCHANGED LOGIC)
# --------------------
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		attack_timer = 0.0

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null

# --------------------
# HEALTH
# --------------------
func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	print("Lizard took damage! Health:", current_health)

	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	sprite.play("death")
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)

	if not sprite.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished() -> void:
	var death_timer := Timer.new()
	death_timer.wait_time = 3.0
	death_timer.one_shot = true
	add_child(death_timer)
	death_timer.connect("timeout", Callable(self, "_on_death_timer_timeout"))
	death_timer.start()

func _on_death_timer_timeout() -> void:
	queue_free()
