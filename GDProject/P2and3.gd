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


func assignLabels(lst: Array[String]):
	for idx in symbols.size():
		symbols[idx].get_node("RichTextLabel").text = "[center]" + lst[idx]


func _process(delta):
	countdownTick(delta)


func countdownTick(delta):
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func loadLevel():
	var symbolFiles = Game.getSymbolFiles(player)
	for idx in symbols.size():
		symbols[idx].get_node("SymbolContainer/Symbol").texture = load(symbolFiles[idx])


func onGameLost():
	$NotificationLayer.show()
