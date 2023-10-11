extends Control


var selectedP2: int = 0
var selectedP3: int = 0

var nextNotifShown: bool = false
var wrongNotifShown: bool = false


func _ready():
	recoverFocus()
	$MainLayer/LetterDial/VerticalContainer/Dial.set_meta("player", Game.Player.P2)
	$MainLayer/NumberDial/VerticalContainer/Dial.set_meta("player", Game.Player.P3)
	$MainLayer/CountdownBar.max_value = Game.countdownSeconds
	$MainLayer/CountdownBar.value = Game.remainingSeconds
	loadLevel()
	Game.puzzleChanged.connect(loadLevel)
	Game.timeEnded.connect(onGameLost)
	Game.gameRunStateChanged.connect(onGameRunStateChanged)
	Game.resetCalled.connect(reset)
	Game.gameWon.connect(onGameWon)


func _process(delta):
	countdownTick(delta)
	if Input.is_action_just_pressed("Confirm"):
		if nextNotifShown:
			$NotificationLayer/NextNotif.hide()
			nextNotifShown = false
			Game.isGameRunning = true
			return
		elif wrongNotifShown:
			$NotificationLayer/WrongNotif.hide()
			wrongNotifShown = false
			return
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
			if not Game.isGameWon:
				$NotificationLayer/NextNotif.show()
				nextNotifShown = true
		else:
			print("YOU FUCKING DONKEY")
			Game.wrongGuess()
			showHearts()
			if Game.currentHealth == 0:
				var score: int = Game.getScore()
				$NotificationLayer/LostNotif.changeText("You lost! Score: " + str(score))
				$NotificationLayer/LostNotif.show()
			else:
				$NotificationLayer/WrongNotif.show()
				wrongNotifShown = true


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


func countdownTick(_delta):
	$MainLayer/CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$MainLayer/CountdownBar.value = Game.remainingSeconds


func loadLevel():
	$MainLayer/SolutionContainer/SolutionTexture.texture = load(Game.getSymbolFiles(Game.Player.P1)[0])


func isSolutionCorrect():
	return selectedP2 == Game.solutionPosition[0] and selectedP3 == Game.solutionPosition[1]


func onGameLost():
	var score: int = Game.getScore()
	$NotificationLayer/LostNotif.changeText("You ran out of time! Score: " + str(score))
	$NotificationLayer/LostNotif.show()


func onGameWon():
	var score: int = Game.getScore()
	$NotificationLayer/WinNotif.changeText("You won! Score: " + str(score))
	$NotificationLayer/WinNotif.show()


func onGameRunStateChanged(value: bool):
	$MainLayer/SolutionContainer/SolutionTexture.visible = value
	if value:
		recoverFocus()


func recoverFocus():
	$MainLayer/LetterDial.grab_focus()


func showHearts():
	var hearts = $MainLayer/HeartContainer.get_children()
	for heart in hearts:
		heart.hide()
	for i in Game.currentHealth:
		hearts[i].show()


func reset():
	$NotificationLayer/LostNotif.hide()
	$NotificationLayer/WinNotif.hide()
	$NotificationLayer/NextNotif.hide()
	$NotificationLayer/WrongNotif.hide()
	showHearts()
