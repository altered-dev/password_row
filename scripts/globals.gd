extends Node

var colors := [Color("#ff8080"), Color("#ffbf80"), Color("#80bfff"), Color("#ff80d4")]

var symbols := [
	"QWERTYUIOPASDFGHJKLZXCVBNM",
	"qwertyuiopasdfghjklzxcvbnm",
	"1234567890",
	"`~!@#$%^&*()-_=+[]{}\\|/?.>,<;:",
]

var last_password := ""


func _ready():
	randomize()


func pick_random(symbols: String) -> String:
	return symbols[randi() % symbols.length()]
