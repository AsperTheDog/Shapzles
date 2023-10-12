extends Node

@export var timeBarGradient: Gradient

func _ready():
	Game.isGameRunning = false
	Logger.clearedLogs.connect(emptyLogTable)


func _process(_delta):
	$Control/Info.text = "[b]Current level:[/b] %d\n[b]Game:[/b] %s\n[b]Counter:[/b] %s\n[b]Current Health: [/b] %d" % [
		Game.currentLevel,
		"Running" if Game.isGameRunning else "Paused",
		Game.getStringFromCountdown(),
		Game.currentHealth
		]
	updateLogTable()


@onready var logContainer: VBoxContainer = $Control/Logs/MainContainer/ScrollContainer/VBoxContainer as VBoxContainer
@onready var logPlaceholder: HBoxContainer = $Control/Logs/MainContainer/ScrollContainer/VBoxContainer/placeholder as HBoxContainer
@onready var logSeparator: HSeparator = $Control/Logs/MainContainer/ScrollContainer/VBoxContainer/placeholderSeparator as HSeparator
var logCount: int = 0
func updateLogTable():
	var maxValue: float = -1
	for puzzle in Logger.logs: 
		maxValue = max(puzzle.getTime(), maxValue)
	
	var timeBarSize = logPlaceholder.get_node("time/bar").size.x
	for puzzle in Logger.logs:
		var row: HBoxContainer
		if not logContainer.has_node(puzzle.index):
			logCount += 1
			row = logPlaceholder.duplicate()
			row.name = puzzle.index
			row.get_node("number").text = str(logCount)
			row.show()
			logContainer.add_child(row)
			var separator = logSeparator.duplicate()
			separator.show()
			logContainer.add_child(separator)
		else:
			row = logContainer.get_node(puzzle.index)
		row.get_node("index").text = puzzle.index
		row.get_node("diff").text = str(puzzle.diff)
		row.get_node("time").text = puzzle.getTimeStr()
		row.get_node("errors").text = "[color=%s]" % ("green" if puzzle.errors == 0 else "yellow") + str(puzzle.errors)
		row.get_node("completed").text = "[color=green]yes" if puzzle.completed else "[color=orange]no"
		var timePercentage: float = puzzle.getTime() / maxValue if maxValue != 0.0 else 1.0
		row.get_node("time/bar").size.x = timeBarSize * timePercentage
		row.get_node("time/bar").color = timeBarGradient.sample(timePercentage)


func emptyLogTable():
	for child in logContainer.get_children().filter(func(elem): return not elem.name.contains("placeholder")):
		child.free()
	logCount = 0


func _on_reset_pressed() -> void:
	Game.reset()
	$P1/P1.recoverFocus()


func _on_toggle_game_pressed() -> void:
	Game.toggleGame()
	$P1/P1.recoverFocus()


func _on_solve_puzzle_pressed() -> void:
	$P1/P1.onLevelCompleted()
