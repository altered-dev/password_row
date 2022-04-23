extends Control


func _ready() -> void:
	$password.text = Globals.last_password


func _on_play_pressed() -> void:
	get_tree().change_scene("res://scenes/field.tscn")
