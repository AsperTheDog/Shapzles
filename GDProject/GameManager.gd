extends Node

signal puzzleChanged
signal timeEnded

enum Player {
	P1,
	P2,
	P3
}

var maxSymbols: int = 6
var letters: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
var numbers: Array[String] = ['1', '2', '3', '4', '5', '6', '7', '8', '9']

var countdownSeconds: int = 300
@onready var remainingSeconds = countdownSeconds
var penaltyAmount: int = 0

var symbolData: Dictionary = preload("res://Symbols/symbolTable.json").data
		
var currentPuzzle: int
var currentLevel: String:
	set(value):
		if currentLevel == value: return
		currentLevel = value
		if not currentLevel in symbolData: return
		if symbolData[currentLevel].size() != 0:
			currentPuzzle = randi_range(0, symbolData[currentLevel].size() - 1)
			maxSymbols = symbolData[currentLevel][currentPuzzle]['P2'].size()
			puzzleChanged.emit()

var isGameRunning: bool = false


func _ready():
	currentLevel = "level 1"
	isGameRunning = true


func _process(delta):
	if isGameRunning:
		countdownTick(delta)


func countdownTick(delta) -> void:
	remainingSeconds = max(0, remainingSeconds - delta)
	if remainingSeconds == 0:
		isGameRunning = false
		timeEnded.emit()
		return
	var mins := int(remainingSeconds) / 60
	var seconds := int(remainingSeconds) % 60


func getStringFromCountdown() -> String:
	var mins := int(remainingSeconds) / 60
	var seconds := int(remainingSeconds) % 60
	var newText = ("%02d" % mins) + ":" + ("%02d" % seconds)
	if penaltyAmount != 0:
		newText += "[color=red] -" + str(penaltyAmount)
	return newText


func getSymbolFiles(player: Player) -> Array[String]:
	if not currentLevel in symbolData: return []
	var fileArray: Array[String] = []
	match player:
		Player.P1: fileArray.assign([symbolData[currentLevel][currentPuzzle]["P1"]['SymbolFile']])
		Player.P2: fileArray.assign(symbolData[currentLevel][currentPuzzle]["P2"])
		Player.P3: fileArray.assign(symbolData[currentLevel][currentPuzzle]["P3"])
		_: return []
	for i in fileArray.size():
		fileArray[i] = "res://Symbols/" + fileArray[i]
	return fileArray


func getCorrectSolution() -> Array[int]:
	return [symbolData[currentLevel][currentPuzzle]["P1"]["P2SolutionIndex"],
			symbolData[currentLevel][currentPuzzle]["P1"]["P3SolutionIndex"]]


func requestNextLevel():
	var regex = RegEx.new()
	regex.compile("level (?<digit>\\d)")
	var nextLevel = "level " + str(int(regex.search(currentLevel).get_string("digit")) + 1)
	currentLevel = nextLevel


func penalizeTimer(amount: int):
	remainingSeconds = max(0, remainingSeconds - amount)
	penaltyAmount = amount
	get_tree().create_timer(3).timeout.connect(func(): penaltyAmount = 0)
