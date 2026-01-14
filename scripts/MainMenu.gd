extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var story_button: Button = $CenterContainer/VBoxContainer/StoryButton
@onready var help_button: Button = $CenterContainer/VBoxContainer/HelpButton
@onready var info_panel: Control = $InfoPanel

const STORY_TEXT := """
In a forgotten coastal land lived a fisherman who believed in honesty and hard work, not gods or divine judgment. When religious clerics arrived demanding faith and obedience, he refused—not out of defiance, but conviction.

Soon after, his young son died from a sudden illness. No prayer was answered. No miracle came. When the clerics returned, they delivered their final cruelty: because the child had never accepted their god, his soul was condemned to Hell.

Grief turned into rage. If Hell existed—and if it held his innocent son—then the fisherman would descend into it himself. Armed only with his will and a blade meant for survival, he enters the underworld to fight demons, defy gods, and reclaim what was taken from him.

This is not a holy quest.
It is a father’s war.
"""

const HELP_TEXT := """
Movement

A – Move Left
D – Move Right
Space – Jump

Combat

X – Attack
C – Attack

Items:
Blue bottles restore health when collected.
"""



func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	story_button.pressed.connect(_on_story_pressed)
	help_button.pressed.connect(_on_help_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/GameRoot.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_story_pressed():
	info_panel.show_info("Story", STORY_TEXT)

func _on_help_pressed():
	info_panel.show_info("Help", HELP_TEXT)
