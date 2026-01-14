extends Control

@onready var title_label: Label = $PanelContainer/Content/TitleLabel
@onready var body_label: Label = $PanelContainer/Content/Scroll/BodyLabel
@onready var back_button: Button = $PanelContainer/Content/BackButton

func _ready():
	back_button.pressed.connect(hide_panel)
	hide()

func show_info(title: String, text: String):
	title_label.text = title
	body_label.text = text
	show()

func hide_panel():
	hide()

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		hide_panel()
