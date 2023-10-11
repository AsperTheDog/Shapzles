extends Node
class_name PuzzleLogger

signal clearedLogs


class PuzzleLog:
	var startingTime: float = 0
	var finishTime: float = 0
	var index: String
	var diff: int = 0
	var errors: int = 0
	var completed: bool = false
	
	func _init(idx: String, difficulty: int):
		index = idx
		diff = difficulty
		startingTime = Game.getCurrentTime()
	
	func getTime() -> float:
		if not completed:
			return Game.getCurrentTime() - startingTime
		else:
			return finishTime - startingTime
	
	func getTimeStr():
		var time: float = getTime()
		var mins := int(time) / 60
		var seconds := int(time) % 60
		var newText := ("%02d" % mins) + ":" + ("%02d" % seconds)
		return newText

	func logInTerminal():
		print("Puzzle %s (difficulty %s) solved with time %s and %s errors" % [index, diff, getTimeStr(), errors])


var logs: Array[PuzzleLog] = []
var currentLog: PuzzleLog = null


func addPuzzle(idx: String, diff: int):
	logs.append(PuzzleLog.new(idx, diff))
	completePuzzle()
	if currentLog != null:
		currentLog.logInTerminal()
	currentLog = logs.back()


func registerError():
	if currentLog == null: return
	currentLog.errors += 1


func completePuzzle():
	if currentLog == null: return
	currentLog.completed = true
	currentLog.finishTime = Game.getCurrentTime()


func clear():
	currentLog = null
	logs.clear()
	clearedLogs.emit()
