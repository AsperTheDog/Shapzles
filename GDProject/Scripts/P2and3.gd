extends Control

@export var player: Game.Player
@onready var heartSize: Vector2 = $MainLayer/HeartContainer/TextureRect.size

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
	$NotificationLayer/LostNotif.hideFooter()
	
	$NotificationLayer.hide()
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	assignLabels(Game.letters if player == Game.Player.P2 else Game.numbers)
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)
	Game.gameRunStateChanged.connect(onGameRunStateChanged)
	Game.resetCalled.connect(reset)
	Game.answeredWrong.connect(onWrongAnswer)
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


func onWrongAnswer():
	showHearts()


func showHearts():
	var hearts = $MainLayer/HeartContainer.get_children()
	for i in hearts.size():
		if i >= Game.currentHealth:
			if not hearts[i].visible: continue
			var origPos = hearts[i].global_position
			var tween: Tween = create_tween()
			tween.tween_method(animateHeart.bind(hearts[i], origPos), 0.0, 1.0, 0.2)
			tween.tween_callback(func(): hearts[i].hide())
			tween.tween_callback(func(): hearts[i].size = heartSize) 
			tween.tween_callback(func(): hearts[i].global_position = origPos) 
		else:
			hearts[i].visible = true


func animateHeart(value: float, heart: TextureRect, origPos: Vector2):
	heart.size = Game.heartCurve.sample(value) * heartSize
	var sizeDiff = heartSize - heart.size
	heart.global_position = origPos + (sizeDiff / 2)


func reset():
	$NotificationLayer.hide()
	showHearts()
