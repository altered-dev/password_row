extends Node2D
class_name Field

export var symbol_scene: PackedScene
export var width: int
export var height: int
export var symbol_size: int
export var symbol_spacing: int

onready var step := symbol_size + symbol_spacing
onready var start := Vector2(1 - width, 1 - height) * (step) / 2

var held_symbol
onready var max_distance := sqrt(2) * (step) + 1


func _ready() -> void:
	$symbols.position = get_viewport().size / 2
	spawn_symbols()
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")


func spawn_symbols() -> void:
	for i in range(width):
		for j in range(height):
			spawn_symbol(start + Vector2(i, j) * step)


func spawn_symbol(position: Vector2):
	var symbol = symbol_scene.instance()
	symbol.field = self
	symbol.global_position = position
	$symbols.add_child(symbol)
	return symbol


func _on_viewport_size_changed() -> void:
	$symbols.position = get_viewport().size / 2


func reset_held() -> void:
	held_symbol = null


func find_at_pos(start_pos: Vector2):
	var res = []
	for symbol in $symbols.get_children():
		if symbol.start_pos == start_pos:
			res.append(symbol)
	return res


func find_existing_at_pos(start_pos: Vector2):
	var res = []
	for symbol in $symbols.get_children():
		if symbol.start_pos == start_pos and !symbol._removed:
			res.append(symbol)
	return res


func check_for_matches() -> void:
	for symbol in $symbols.get_children():
		symbol.check_for_matches()
	fill()


func fill() -> void:
	for symbol in $symbols.get_children():
		if symbol._removed:
			for i in range(height):
				for s in find_existing_at_pos(symbol.start_pos + Vector2.UP * step * i):
					s.fall(1)
			var new_pos := Vector2(symbol.start_pos.x - $symbols.position.x, start.y)
			var new_s = spawn_symbol(new_pos)
			new_s.position = new_pos
			new_s.add()
	$timer.start()


func push_letter(letter: String) -> void:
	$canvas/password.text += letter


func _on_exit_pressed() -> void:
	Globals.last_password = $canvas/password.text.substr(12)
	get_tree().change_scene("res://scenes/game_over.tscn")
