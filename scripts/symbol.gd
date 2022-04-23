extends KinematicBody2D
class_name Symbol

var type: int
var field: Field
var is_held = false
var start_pos: Vector2

var _visited = false
var _removed = false
onready var parent: Node2D = get_parent()


func _ready():
	start_pos = global_position
	randomize()
	type = randi() % 4
	$sprite.self_modulate = Globals.colors[type]
	$char.text = Globals.pick_random(Globals.symbols[type])


func _physics_process(delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()
		if start_pos.distance_to(global_position) > field.max_distance:
			global_position = start_pos + (global_position - start_pos) \
				/ start_pos.distance_to(global_position) * field.max_distance


func _on_symbol_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			field.held_symbol = self
			is_held = true
			$tween.stop_all()
		else:
			if is_held:
				move_to_start()
				field.call_deferred("reset_held")
				is_held = false
			elif field.held_symbol != null:
				call_deferred("swap", field.held_symbol)


func swap(other: Symbol) -> void:
	if start_pos.distance_to(other.start_pos) > field.max_distance:
		return
	other.get_node("tween").stop_all()
	var temp := other.start_pos
	other.start_pos = start_pos
	start_pos = temp
	var self_checked = check_for_matches()
	var other_checked = other.check_for_matches()
	if self_checked or other_checked:
		field.fill()
	else:
		temp = other.start_pos
		other.start_pos = start_pos
		start_pos = temp
	move_to_start()
	other.move_to_start()


func move_to_start() -> void:
	$tween.interpolate_property(self, "global_position", null, start_pos, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()


func fall(tiles: int) -> void:
	start_pos.y += tiles * field.step
	move_to_start()


func get_chain(direction: Vector2) -> Array:
	var res = []
	_visited = true
	call_deferred("_reset_visited")
	var symbols = field.find_existing_at_pos(start_pos + direction)
	for symbol in symbols:
		if !symbol._visited and symbol.type == type:
			res.append(symbol)
			res.append_array(symbol.get_chain(direction))
	return res


func _reset_visited() -> void:
	_visited = false
	

func _reset_removed() -> void:
	_removed = false


func check_for_matches() -> bool:
	var vertical = [self] + get_chain(Vector2(0, field.step)) + get_chain(Vector2(0, -field.step))
	var horizontal = [self] + get_chain(Vector2(field.step, 0)) + get_chain(Vector2(-field.step, 0))
	var flag = false
	if vertical.size() >= 3:
		for s in vertical:
			s.check_for_matches()
			s.remove()
		flag = true
	if horizontal.size() >= 3:
		for s in horizontal:
			s.check_for_matches()
			s.remove()
		flag = true
	if flag:
		field.push_letter($char.text)
	return flag


func add() -> void:
	$tween.interpolate_property(self, "scale", Vector2.ZERO, Vector2.ONE, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()


func remove() -> void:
	_removed = true
	call_deferred("_reset_removed")
	$tween.interpolate_property(self, "scale", null, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()
	$tween.connect("tween_all_completed", self, "queue_free")
