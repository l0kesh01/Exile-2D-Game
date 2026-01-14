extends CharacterBody2D

# --------------------
# CONFIG
# --------------------
@export var SPEED: float = 70.0
@export var ATTACK_RANGE: float = 35.0
@export var patrol_distance: float = 50.0
@export var ATTACK_COOLDOWN: float = 1.0
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
	var horizontal_distance = abs(to_player.x)

	if horizontal_distance > ATTACK_RANGE:
		velocity = Vector2(sign(to_player.x), 0) * SPEED
		_update_facing(velocity.x)
		sprite.play("Skel_run")
	else:
		velocity = Vector2.ZERO
		sprite.play("Skel_Att1")
		attack_timer -= delta

		if attack_timer <= 0:
			if player.has_method("take_damage"):
				player.take_damage(1)
			attack_timer = ATTACK_COOLDOWN

func _patrol():
	velocity.x = patrol_direction * SPEED
	_update_facing(velocity.x)
	sprite.play("Skel_run")

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
# DETECTION
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
	print("Skeleton took damage! Health:", current_health)

	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	await get_tree().create_timer(1).timeout  # small pause
	sprite.play("Skel_Dead")

	if not sprite.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished() -> void:
	queue_free()


func _on_detection_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.


func _on_detection_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
