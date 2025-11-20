extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
@export var respawn_time: float = 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D         # idle, run, jump, dead
@onready var sprite_attack: AnimatedSprite2D = $AnimatedSprite2D2 # attack_1 and attack_2
@onready var attack_area: Area2D = $AttackArea2D
@onready var attack_shape: CollisionShape2D = $AttackArea2D/CollisionShape2D

var is_attacking = false
var is_dead = false
var health = 25
var attack_damage = 1
var hit_enemies = []
var max_health=30
func _ready():
	sprite.visible = true
	sprite_attack.visible = false
	attack_area.monitoring = false
	hit_enemies.clear()
	# ✅ Connect signal here
	#attack_area.body_entered.connect(_on_attack_area_body_entered)
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	handle_movement(delta)
	handle_animation()

func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and not is_attacking:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		sprite_attack.flip_h = direction < 0

		update_attack_area_position(direction < 0)
	elif not is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if not is_attacking:
		if Input.is_action_just_pressed("attack_1"):
			start_attack("attack_1")
		elif Input.is_action_just_pressed("attack_2"):
			start_attack("attack_2")

func update_attack_area_position(facing_left: bool):
	var shape_offset = abs(attack_area.position.x)
	attack_area.position.x = -shape_offset if facing_left else shape_offset

func handle_animation():
	if is_attacking or is_dead:
		return

	if not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

func start_attack(anim_name: String) -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	sprite.visible = false
	sprite_attack.visible = true

	hit_enemies.clear()
	attack_area.monitoring = true

	sprite_attack.play(anim_name)
	await sprite_attack.animation_finished

	attack_area.monitoring = false
	sprite_attack.visible = false
	sprite.visible = true
	is_attacking = false

func _on_attack_area_body_entered(body: Node) -> void:
	if is_attacking and body.has_method("take_damage") and not hit_enemies.has(body):
		print("HIT: ", body.name)
		body.take_damage(attack_damage)
		hit_enemies.append(body)

func take_damage(amount: int):
	health -= amount
	print("Player took damage! Health: ", health)
	if health <= 0:
		die()

func die():
	if is_dead:
		print("Player is dead!")
		return
	is_dead = true
	sprite.play("dead")
	sprite_attack.visible = false
	sprite.visible = true
	set_physics_process(false)
	call_deferred("_delayed_restart")

func _delayed_restart():
	await get_tree().create_timer(respawn_time).timeout
	if get_tree():
		get_tree().reload_current_scene()

func restart_level():
	get_tree().reload_current_scene()

@export var fall_death_offset: float = 250.0
var fall_timer_started = false

func heal_full():
	health = max_health
	print("Player healed to full!")
