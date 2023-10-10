extends Node

signal puzzleChanged
signal timeEnded

signal gameRunStateChanged(runState: bool)

enum Player {
	P1,
	P2,
	P3
}

var maxSymbols: int = 6
var letters: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
var numbers: Array[String] = ['1', '2', '3', '4', '5', '6', '7', '8', '9']

var maxHealth: int = 3
var currentHealth: int = maxHealth
var countdownSeconds: int = 300
@onready var remainingSeconds = countdownSeconds

var symbolData: Dictionary = preload("res://Symbols/symbolTable.json").data
@onready var solutionPosition: Array[int]

var currentPuzzle: int
var currentLevel: int:
	set(value):
		if currentLevel == value: return
		currentLevel = value
		if not currentLevel in symbolData: 
			reset()
		if symbolData[currentLevel].size() != 0:
			currentPuzzle = randi_range(0, symbolData[currentLevel].size() - 1)
			maxSymbols = symbolData[currentLevel][currentPuzzle]['P2'].size()
			solutionPosition = getDefaultSolution()
			puzzleChanged.emit()

var isGameRunning: bool = false:
	set(value):
		isGameRunning = value
		gameRunStateChanged.emit(value)


func _ready():
	for elem in symbolData.keys():
		symbolData[int(elem)] = symbolData[elem]
		symbolData.erase(elem)
	currentLevel = 1


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


func getDefaultSolution() -> Array[int]:
	return [symbolData[currentLevel][currentPuzzle]["P1"]["P2SolutionIndex"],
			symbolData[currentLevel][currentPuzzle]["P1"]["P3SolutionIndex"]]


func getStringFromCountdown() -> String:
	var mins := int(remainingSeconds) / 60
	var seconds := int(remainingSeconds) % 60
	var newText = ("%02d" % mins) + ":" + ("%02d" % seconds)
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


func requestNextLevel():
	var nextLevel = currentLevel + 1
	currentLevel = nextLevel

func wrongGuess():
	currentHealth -= 1
	print("Remaining health: %d" % currentHealth)
	showHearts()
	if currentHealth <= 0:
		reset()

func showHearts():
	'''
	var hearts = $MainLayer/HeartContainer.get_children()
	for heart in hearts:
		heart.hide()
	for i in currentHealth:
		hearts[i].show()
	'''

func reset():
	currentLevel = 1
	remainingSeconds = countdownSeconds
	currentHealth = maxHealth
	showHearts()
	isGameRunning = false


func toggleGame():
	isGameRunning = not isGameRunning
