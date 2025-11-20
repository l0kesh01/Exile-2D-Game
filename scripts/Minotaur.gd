extends CharacterBody2D

signal boss_defeated

@export var SPEED: float = 50.0
@export var ATTACK_RANGE: float = 50.0
@export var PATROL_DISTANCE: float = 75.0
@export var ATTACK_COOLDOWN: float = 1.5
@export var MAX_HEALTH: int = 5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

var current_health: int
var player: Node = null
var start_position: Vector2
var patrol_direction := 1
var patrol_timer := 0.0
const PATROL_TIME := 2.0
var attack_timer := 0.0
var is_dead := false
var direction := Vector2.ZERO

func _ready():
	current_health = MAX_HEALTH
	start_position = global_position
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta):
	if is_dead:
		return

	if player:
		var to_player = player.global_position - global_position
		var distance_to_player = to_player.length()

		if distance_to_player > ATTACK_RANGE:
			direction = to_player.normalized()
			velocity = direction * SPEED
			sprite.flip_h = direction.x < 0
			_update_detection_position()
			sprite.play("walk")
		else:
			velocity = Vector2.ZERO
			sprite.play("attackMin")
			attack_timer -= delta

			var is_facing_player = (to_player.x < 0 and sprite.flip_h) or (to_player.x > 0 and not sprite.flip_h)

			if attack_timer <= 0 and is_facing_player:
				if player.has_method("take_damage"):
					player.take_damage(1)
				attack_timer = ATTACK_COOLDOWN
	else:
		_patrol(delta)

	move_and_slide()

func _patrol(delta):
	patrol_timer += delta
	if patrol_timer >= PATROL_TIME:
		patrol_timer = 0
		patrol_direction *= -1

	direction = Vector2(patrol_direction, 0)
	velocity = direction * SPEED
	sprite.flip_h = direction.x < 0
	sprite.play("walk")

func _update_detection_position():
	if sprite.flip_h:
		detection_area.position.x = -abs(detection_area.position.x)
	else:
		detection_area.position.x = abs(detection_area.position.x)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		player = body
		attack_timer = 0.0

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	print("Minotaur took damage! Health:", current_health)

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	print("Minotaur died!")
	sprite.play("deathMin")

	# disable movement
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)

	# emit signal *only once*
	emit_signal("boss_defeated")

	# connect animation finish → remove body
	if not sprite.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished():
	queue_free()
