extends Control


@export var player: Game.Player

@onready var symbols: Array[PanelContainer] = [
	$MainLayer/Symbols/HorizContainer/Symbol1,
	$MainLayer/Symbols/HorizContainer/Symbol2,
	$MainLayer/Symbols/HorizContainer/Symbol3,
	$MainLayer/Symbols/HorizContainer/Symbol4,
	$MainLayer/Symbols/HorizContainer/Symbol5,
	$MainLayer/Symbols/HorizContainer/Symbol6
]

var symbolLayouts: Dictionary = {
	3: 3,
	4: 2,
	5: 3,
	6: 3
}


func _ready():
	$NotificationLayer.hide()
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	assignLabels(Game.letters if player == Game.Player.P2 else Game.numbers)
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)
	Game.gameRunStateChanged.connect(setSymbolsVisibility)
	Game.resetCalled.connect(reset)


func assignLabels(lst: Array[String]):
	for idx in symbols.size():
		symbols[idx].get_node("Margin/VBox/RichTextLabel").text = "[center]" + lst[idx]


func _process(delta):
	countdownTick(delta)


func countdownTick(_delta):
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func loadLevel():
	setPanelsVisibility(false)
	var symbolFiles = Game.getSymbolFiles(player)
	var idxArr = range(symbolFiles.size())
	var symbolPos := 0
	idxArr.shuffle()
	var playerPos = 0 if player == Game.Player.P2 else 1
	var origSolution = Game.solutionPosition[playerPos]
	$MainLayer/Symbols/HorizContainer.columns = symbolLayouts[symbolFiles.size()]
	for idx in idxArr:
		symbols[symbolPos].show()
		symbols[symbolPos].get_node("Margin/VBox/SymbolContainer/Symbol").texture = load(symbolFiles[idx])
		if origSolution == idx:
			Game.solutionPosition[playerPos] = symbolPos
		symbolPos += 1


func onGameLost():
	$NotificationLayer.show()


func setPanelsVisibility(areVibisle: bool):
	for symbol in symbols:
		symbol.visible = areVibisle


func setSymbolsVisibility(value: bool):
	for symbol in symbols:
		symbol.get_node("Margin/VBox/SymbolContainer/Symbol").visible = value


func reset():
	$NotificationLayer.hide()
