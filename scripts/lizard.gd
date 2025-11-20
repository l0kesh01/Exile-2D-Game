extends CharacterBody2D

@export var SPEED: float = 50.0
@export var ATTACK_RANGE: float = 50.0
@export var patrol_distance: float = 75.0
@export var ATTACK_COOLDOWN: float = 1.5
@export var max_health: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

var current_health: int
var player = null
var start_position: Vector2
var direction = Vector2.ZERO
var patrol_direction := 1
var patrol_timer := 0.0
const PATROL_TIME = 2.0

var attack_timer := 0.0

func _ready():
	current_health = max_health
	start_position = global_position

func _physics_process(delta):
	if player:
		var to_player = player.global_position - global_position
		var distance_to_player = to_player.length()

		if distance_to_player > ATTACK_RANGE:
			# Chase player
			direction = to_player.normalized()
			velocity = direction * SPEED

			# Face the direction of movement
			sprite.flip_h = direction.x < 0
			if direction.x != 0:
				var facing_left = direction.x < 0
				$DetectionArea.position.x = -abs($DetectionArea.position.x) if facing_left else abs($DetectionArea.position.x)
			sprite.play("walk")
		else:
			# Stop and attack only if facing the player
			velocity = Vector2.ZERO
			sprite.play("attack")
			attack_timer -= delta

			var is_facing_player = (to_player.x < 0 and sprite.flip_h) or (to_player.x > 0 and not sprite.flip_h)

			if attack_timer <= 0 and is_facing_player:
				if player.has_method("take_damage"):
					player.take_damage(1)
					print("Lizard attacked player!")
				attack_timer = ATTACK_COOLDOWN
	else:
		# Patrol when no player
		patrol(delta)

	move_and_slide()

func patrol(delta):
	patrol_timer += delta
	if patrol_timer >= PATROL_TIME:
		patrol_timer = 0
		patrol_direction *= -1  # Change direction

	direction = Vector2(patrol_direction, 0)
	velocity = direction * SPEED
	sprite.flip_h = direction.x < 0
	sprite.play("walk")

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		attack_timer = 0.0  # Reset attack cooldown when detected

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null

var health := 3
var is_dead := false

func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Lizard took damage! Health: ", health)

	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	print("Lizard died!")
	$AnimatedSprite2D.play("death")
# Play death animation
	set_physics_process(false)  # Stop movement/logic
	set_collision_layer(0)
	set_collision_mask(0)
	
	if not $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_on_death_animation_finished")):
		$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

func _on_death_animation_finished() -> void:
	print("Death animation finished.")
	
	var death_timer = Timer.new()
	death_timer.wait_time = 3.0
	death_timer.one_shot = true
	add_child(death_timer)
	death_timer.connect("timeout", Callable(self, "_on_death_timer_timeout"))
	death_timer.start()

		
func _on_death_timer_timeout() -> void:
	queue_free()
