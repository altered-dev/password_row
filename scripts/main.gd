extends Control


func _ready():
	pass


func _on_play_pressed():
	get_tree().change_scene("res://scenes/guide.tscn")
