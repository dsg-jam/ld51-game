extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/VBoxContainer/HBoxContainer/IDValue.text = GlobalVariables.id
	pass # Replace with function body.
