extends Node

signal gameWon

signal puzzleChanged
signal timeEnded
signal resetCalled

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
var countdownSeconds: int = 5 * 60
@onready var remainingSeconds: float = float(countdownSeconds)

var gameData: Dictionary = preload("res://symbolTable.json").data
var symbolData: Dictionary = gameData['puzzles']
var progressData: Array[int] = []
var progress: int = 0
var puzzlesDone: Dictionary = {}
@onready var solutionPosition: Array[int]

var currentPuzzle: int
var currentLevel: int:
	set(value):
		var prevLevel = currentLevel
		currentLevel = value
		isGameRunning = false
		if not currentLevel in symbolData:
			gameWon.emit()
			isGameWon = true
			Logger.completePuzzle()
		elif symbolData[currentLevel].size() != 0:
			currentPuzzle = randi_range(0, symbolData[currentLevel].size() - 1)
			while currentPuzzle in puzzlesDone[currentLevel]:
				currentPuzzle = randi_range(0, symbolData[currentLevel].size() - 1)
			puzzlesDone[currentLevel].append(currentPuzzle)
			maxSymbols = symbolData[currentLevel][currentPuzzle]['P2'].size()
			solutionPosition = getDefaultSolution()
			puzzleChanged.emit()
			Logger.addPuzzle(symbolData[currentLevel][currentPuzzle]['index'], currentLevel)

var isGameWon: bool = false


var isGameRunning: bool = false:
	set(value):
		isGameRunning = value
		gameRunStateChanged.emit(value)


func _ready():
	progressData.assign(gameData['progress'])
	for elem in symbolData.keys():
		symbolData[int(elem)] = symbolData[elem]
		symbolData.erase(elem)
		puzzlesDone[int(elem)] = []
	currentLevel = progressData[progress]


func _process(delta):
	if isGameRunning:
		countdownTick(delta)


func countdownTick(delta) -> void:
	remainingSeconds = max(0, remainingSeconds - delta)
	if remainingSeconds == 0:
		isGameRunning = false
		timeEnded.emit()
		return


func getDefaultSolution() -> Array[int]:
	return [symbolData[currentLevel][currentPuzzle]["P1"]["P2SolutionIndex"],
			symbolData[currentLevel][currentPuzzle]["P1"]["P3SolutionIndex"]]


func getStringFromCountdown() -> String:
	var mins := int(remainingSeconds) / 60
	var seconds := int(remainingSeconds) % 60
	var newText := ("%02d" % mins) + ":" + ("%02d" % seconds)
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


func requestLevel(level: int):
	progress = level
	if progress >= progressData.size():
		isGameWon = true
		gameWon.emit()
		isGameRunning = false
		Logger.completePuzzle()
		return
	currentLevel = progressData[progress]


func requestNextLevel():
	requestLevel(progress + 1)


func wrongGuess():
	Logger.registerError()
	currentHealth -= 1
	print("Remaining health: %d" % currentHealth)
	if currentHealth <= 0:
		isGameRunning = false


func reset():
	print("--------- GAME RESET ---------")
	remainingSeconds = countdownSeconds
	currentHealth = maxHealth
	isGameRunning = false
	isGameWon = false
	Logger.clear()
	for elem in symbolData.keys():
		puzzlesDone[int(elem)] = []
	requestLevel(0)
	resetCalled.emit()
	


func toggleGame():
	isGameRunning = not isGameRunning


func getCurrentTime() -> float:
	return Game.countdownSeconds - Game.remainingSeconds


func getScore() -> int:
	return int(ceil(progress / float(progressData.size()) * 100))
