extends Camera2D

func _ready():
	make_current()
	print("Player camera forced current:", get_path())
