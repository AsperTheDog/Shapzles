extends Control

@export var player: Game.Player

@onready var symbols: Array[PanelContainer] = [
	$Symbols/HorizContainer/Symbol1,
	$Symbols/HorizContainer/Symbol2,
	$Symbols/HorizContainer/Symbol3,
	$Symbols/HorizContainer/Symbol4,
	$Symbols/HorizContainer/Symbol5,
	$Symbols/HorizContainer/Symbol6
]

var symbolLayouts: Dictionary = {
	3: 3,
	4: 2,
	5: 3,
	6: 3
}

var blinkTween: Tween


func _ready():
	$NotificationLayer.hide()
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	assignLabels(Game.letters if player == Game.Player.P2 else Game.numbers)
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)
	Game.gameRunStateChanged.connect(onGameRunStateChanged)
	Game.resetCalled.connect(reset)
	blinkTween = create_tween().set_loops()
	blinkTween.tween_callback(blinkProgressBar)
	blinkTween.tween_interval(0.5)


func assignLabels(lst: Array[String]):
	for idx in symbols.size():
		symbols[idx].get_node("Margin/VBox/RichTextLabel").text = "[center]" + lst[idx]


func _process(delta):
	countdownTick(delta)


func countdownTick(_delta):
	$MainLayer/CountdownBar.get_theme_stylebox("background").border_color = Game.getGradientColor()
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func blinkProgressBar():
	if Game.remainingSeconds > 60 or not Game.isGameRunning: 
		$MainLayer/CountdownBar.self_modulate = Color.WHITE
		return
	elif $MainLayer/CountdownBar.self_modulate == Color.WHITE:
		$MainLayer/CountdownBar.self_modulate = Game.progressAlertColor
	else:
		$MainLayer/CountdownBar.self_modulate = Color.WHITE


func loadLevel():
	setPanelsVisibility(false)
	var symbolFiles = Game.getSymbolFiles(player)
	var idxArr = range(symbolFiles.size())
	var symbolPos := 0
	idxArr.shuffle()
	var playerPos = 0 if player == Game.Player.P2 else 1
	var origSolution = Game.solutionPosition[playerPos]
	$Symbols/HorizContainer.columns = symbolLayouts[symbolFiles.size()]
	for idx in idxArr:
		symbols[symbolPos].show()
		symbols[symbolPos].get_node("Margin/VBox/SymbolContainer/Symbol").texture = load(symbolFiles[idx])
		if origSolution == idx:
			Game.solutionPosition[playerPos] = symbolPos
		symbolPos += 1


func onGameLost():
	$NotificationLayer/LostNotif.changeText("You ran out of time! Score: " + str(Game.getScore()))
	$NotificationLayer.show()


func setPanelsVisibility(areVibisle: bool):
	for symbol in symbols:
		symbol.visible = areVibisle


func onGameRunStateChanged(value: bool):
	if not value:
		blinkProgressBar()
		blinkTween.pause()
	else:
		blinkTween.play()
	for symbol in symbols:
		symbol.get_node("Margin/VBox/SymbolContainer/Symbol").visible = value


func reset():
	$NotificationLayer.hide()
