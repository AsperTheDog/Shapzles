extends Control


@export var player: Game.Player

@onready var symbols: Array[MarginContainer] = [
	$MainLayer/Symbols/HorizContainer/Symbol1,
	$MainLayer/Symbols/HorizContainer/Symbol2,
	$MainLayer/Symbols/HorizContainer/Symbol3
]

func _ready():
	$NotificationLayer.hide()
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	assignLabels(Game.letters if player == Game.Player.P2 else Game.numbers)
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)
	Game.gameRunStateChanged.connect(onGameRunStateChanged)


func assignLabels(lst: Array[String]):
	for idx in symbols.size():
		symbols[idx].get_node("RichTextLabel").text = "[center]" + lst[idx]


func _process(delta):
	countdownTick(delta)


func countdownTick(delta):
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func loadLevel():
	print("\n")
	var symbolFiles = Game.getSymbolFiles(player)
	var idxArr = range(symbols.size())
	var symbolPos := 0
	idxArr.shuffle()
	var playerPos = 0 if player == Game.Player.P2 else 1
	var origSolution = Game.solutionPosition[playerPos]
	for idx in idxArr:
		symbols[symbolPos].get_node("SymbolContainer/Symbol").texture = load(symbolFiles[idx])
		if origSolution == idx:
			Game.solutionPosition[playerPos] = symbolPos
		symbolPos += 1


func onGameLost():
	$NotificationLayer.show()


func onGameRunStateChanged(value: bool):
	$MainLayer/Symbols/HorizContainer/Symbol1/SymbolContainer/Symbol.visible = value
	$MainLayer/Symbols/HorizContainer/Symbol2/SymbolContainer/Symbol.visible = value
	$MainLayer/Symbols/HorizContainer/Symbol3/SymbolContainer/Symbol.visible = value
