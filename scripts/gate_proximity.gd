extends Node2D

@onready var moving_part = $MovingPart
@onready var sprite = $MovingPart/Sprite2D
@onready var gate_collision = $MovingPart/CollisionShape2D
@onready var detection_area = $DetectionArea

var closed_pos : Vector2
var open_pos : Vector2
var speed := 200.0
var is_open := false

func _ready():
	closed_pos = moving_part.position

	var gate_height = sprite.texture.get_height() * sprite.scale.y
	open_pos = closed_pos + Vector2(0, -gate_height)

	detection_area.body_entered.connect(_on_enter)
	detection_area.body_exited.connect(_on_exit)

func _process(delta):
	if is_open:
		moving_part.position = moving_part.position.move_toward(open_pos, speed * delta)
	else:
		moving_part.position = moving_part.position.move_toward(closed_pos, speed * delta)

func _on_enter(body):
	if body.name == "Player":
		is_open = true
		gate_collision.disabled = true

func _on_exit(body):
	if body.name == "Player":
		is_open = false
		gate_collision.disabled = false
