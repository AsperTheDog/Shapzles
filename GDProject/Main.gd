extends Node


func _ready():
	Game.isGameRunning = false


func _process(_delta):
	$Control/Info.text = "[b]Current level:[/b] %d\n[b]Game:[/b] %s\n[b]Counter:[/b] %s\n[b]Current Health: [/b] %d" % [
		Game.currentLevel,
		"Running" if Game.isGameRunning else "Paused",
		Game.getStringFromCountdown(),
		Game.currentHealth
		]


func _on_reset_pressed() -> void:
	Game.reset()
	$P1/P1.recoverFocus()


func _on_toggle_game_pressed() -> void:
	Game.toggleGame()
	$P1/P1.recoverFocus()
