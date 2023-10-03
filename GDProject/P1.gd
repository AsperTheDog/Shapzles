extends Control


@export var failPenaltySeconds: int = 30

var selectedP2: int = 0
var selectedP3: int = 0

func _ready():
	$NotificationLayer.hide()
	$MainLayer/LetterDial.grab_focus()
	$MainLayer/LetterDial/VerticalContainer/Dial.set_meta("player", Game.Player.P2)
	$MainLayer/NumberDial/VerticalContainer/Dial.set_meta("player", Game.Player.P3)
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)


func _process(delta):
	countdownTick(delta)
	if not Game.isGameRunning:
		if get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_get_focus_owner().release_focus()
		return
	var focused: RichTextLabel = get_viewport().gui_get_focus_owner().get_node("VerticalContainer/Dial")
	if Input.is_action_just_pressed("ui_down"):
		onDialChanged(focused, focused.get_meta("player"), -1)
	elif Input.is_action_just_pressed("ui_up"):
		onDialChanged(focused, focused.get_meta("player"), 1)
	elif Input.is_action_just_pressed("Confirm"):
		if isSolutionCorrect():
			print("CORRECT")
			Game.requestNextLevel()
		else:
			print("YOU FUCKING DONKEY")
			Game.penalizeTimer(failPenaltySeconds)


func onDialChanged(label: RichTextLabel, player: Game.Player, dir: int) -> void:
	var lst = Game.letters if player == Game.Player.P2 else Game.numbers
	#var newIdx = clamp(lst.find(label.text.lstrip("[center]")) + dir, 0, Game.maxSymbols - 1)
	var newIdx = lst.find(label.text.lstrip("[center]")) + dir
	if(newIdx < 0):
		newIdx = Game.maxSymbols - 1
	elif(newIdx > Game.maxSymbols - 1):
		newIdx = 0
	
	label.text = "[center]" + lst[newIdx]
	match player:
		Game.Player.P2: selectedP2 = newIdx
		Game.Player.P3: selectedP3 = newIdx


func countdownTick(delta):
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func loadLevel():
	$MainLayer/SolutionContainer/SolutionTexture.texture = load(Game.getSymbolFiles(Game.Player.P1)[0])


func isSolutionCorrect():
	var solutions = Game.getCorrectSolution()
	return selectedP2 == solutions[0] and selectedP3 == solutions[1]


func onGameLost():
	$NotificationLayer.show()
