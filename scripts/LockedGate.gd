extends CharacterBody2D

@export var open_offset: Vector2 = Vector2(0, -80)
@export var move_speed: float = 4.0

var closed_position: Vector2
var open_position: Vector2
var is_open: bool = false

@onready var gate_body: CollisionShape2D = $CollisionShape2D

func _ready():
	closed_position = global_position
	open_position = closed_position + open_offset
	set_physics_process(false)

func open_gate():
	if is_open:
		return
	is_open = true
	set_physics_process(true)

func _physics_process(delta):
	if is_open:
		global_position = global_position.lerp(open_position, delta * move_speed)
		
		if global_position.distance_to(open_position) < 1.0:
			print("Disabling collision")
			gate_body.disabled = true
			set_physics_process(false)


func _on_minotaur_2_boss_defeated() -> void:
	open_gate()
