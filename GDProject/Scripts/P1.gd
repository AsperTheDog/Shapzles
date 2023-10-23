extends Control

signal dialChanged
signal dialShifted

var selectedP2: int = 0
var selectedP3: int = 0

var nextNotifShown: bool = false
var wrongNotifShown: bool = false

var blinkTween: Tween
@onready var heartSize: Vector2 = $MainLayer/HeartContainer/TextureRect.size

var dialPositionDown: float


func _ready():
	$NotificationLayer/WinNotif.hideFooter()
	$NotificationLayer/LostNotif.hideFooter()
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
	blinkTween = create_tween().set_loops()
	blinkTween.tween_callback(blinkProgressBar)
	blinkTween.tween_interval(0.5)
	getDialDown.call_deferred()


func getDialDown():
	dialPositionDown = $MainLayer/LetterDial/VerticalContainer/MarginContainer2.position.y


var currentWinMode: DisplayServer.WindowMode
func _process(delta):
	if Input.is_action_just_pressed("Fullscreen"):
		if currentWinMode == DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
			currentWinMode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		else:
			currentWinMode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
		DisplayServer.window_set_mode(currentWinMode, 1)
		ProjectSettings.set("display/window/size/mode", currentWinMode)
	countdownTick(delta)
	if Input.is_action_just_pressed("Confirm"):
		if nextNotifShown:
			$MainLayer/RichTextLabel.show()
			$NotificationLayer/NextNotif.hide()
			nextNotifShown = false
			Game.isGameRunning = true
			return
		elif wrongNotifShown:
			$MainLayer/RichTextLabel.show()
			$NotificationLayer/WrongNotif.hide()
			wrongNotifShown = false
			return
	if not Game.isGameRunning:
		if get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_get_focus_owner().release_focus()
		return
	var focused: RichTextLabel = get_viewport().gui_get_focus_owner().get_node("VerticalContainer/Dial")
	if Input.is_action_just_pressed("ui_down"):
		animateDial(focused, -1)
		onDialChanged(focused, focused.get_meta("player"), -1)
	elif Input.is_action_just_pressed("ui_up"):
		animateDial(focused, 1)
		onDialChanged(focused, focused.get_meta("player"), 1)
	elif Input.is_action_just_pressed("Confirm"):
		if isSolutionCorrect():
			onLevelCompleted()
		else:
			print("YOU FUCKING DONKEY")
			Game.wrongGuess()
			showHearts()
			if Game.currentHealth == 0:
				Game.gameLost.emit()
				var score: int = Game.getScore()
				hideNotifications()
				$NotificationLayer/LostNotif.changeText("You lost! Score: " + str(score))
				$NotificationLayer/LostNotif.show()
			else:
				hideNotifications()
				$NotificationLayer/WrongNotif.show()
				$MainLayer/RichTextLabel.hide()
				wrongNotifShown = true


func forceDial(label: RichTextLabel, player: Game.Player, value: int):
	var lst = Game.letters if player == Game.Player.P2 else Game.numbers
	label.text = "[center]" + lst[value]
	match player:
		Game.Player.P2: selectedP2 = value
		Game.Player.P3: selectedP3 = value


func onDialChanged(label: RichTextLabel, player: Game.Player, dir: int) -> void:
	var lst = Game.letters if player == Game.Player.P2 else Game.numbers
	var newIdx = lst.find(label.text.lstrip("[center]")) + dir
	if(newIdx < 0):
		newIdx = Game.maxSymbols - 1
	elif(newIdx > Game.maxSymbols - 1):
		newIdx = 0
	
	label.text = "[center]" + lst[newIdx]
	match player:
		Game.Player.P2: selectedP2 = newIdx
		Game.Player.P3: selectedP3 = newIdx
	dialShifted.emit()


func animateDial(dial: RichTextLabel, dir: int):
	var tween: Tween = create_tween()
	var arrow = dial.get_node("../MarginContainer") if dir == 1 else dial.get_node("../MarginContainer2")
	var origPos = Vector2(0, 0 if dir == 1 else dialPositionDown)
	var newPos = origPos
	newPos.y -= 20 * dir
	tween.tween_property(arrow, "position", newPos, 0.2)
	tween.tween_property(arrow, "position", origPos, 0.2)


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
	$MainLayer/CountdownBar/Score.text = "[center]Current score: " + str(Game.getScore())
	forceDial($MainLayer/LetterDial/VerticalContainer/Dial, Game.Player.P2, 0)
	forceDial($MainLayer/NumberDial/VerticalContainer/Dial, Game.Player.P3, 0)
	$SolutionContainer/SolutionPanel/margin/SolutionTexture.texture = load(Game.getSymbolFiles(Game.Player.P1)[0])


func isSolutionCorrect():
	return selectedP2 == Game.solutionPosition[0] and selectedP3 == Game.solutionPosition[1]


func onGameLost():
	Game.gameLost.emit()
	var score: int = Game.getScore()
	hideNotifications()
	$MainLayer/RichTextLabel.hide()
	$NotificationLayer/LostNotif.changeText("You ran out of time! Score: " + str(score))
	$NotificationLayer/LostNotif.show()


func onGameWon():
	var score: int = Game.getScore()
	hideNotifications()
	$MainLayer/RichTextLabel.hide()
	$NotificationLayer/WinNotif.changeText("You won! Score: " + str(score))
	$NotificationLayer/WinNotif.show()
	$MainLayer/CountdownBar/Score.text = "[center]Current score: " + str(score)


func onLevelCompleted():
	print("CORRECT")
	Game.requestNextLevel()
	if not Game.isGameWon:
		Game.answeredRight.emit()
		hideNotifications()
		$NotificationLayer/NextNotif.show()
		nextNotifShown = true


func onGameRunStateChanged(value: bool):
	if not value:
		blinkProgressBar()
		blinkTween.pause()
	else:
		blinkTween.play()
	$SolutionContainer/SolutionPanel/margin/SolutionTexture.visible = value
	if value:
		recoverFocus()


func recoverFocus():
	$MainLayer/LetterDial.grab_focus()


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


func hideNotifications():
	$MainLayer/RichTextLabel.show()
	$NotificationLayer/LostNotif.hide()
	$NotificationLayer/WinNotif.hide()
	$NotificationLayer/NextNotif.hide()
	nextNotifShown = false
	$NotificationLayer/WrongNotif.hide()
	wrongNotifShown = false


func reset():
	hideNotifications()
	showHearts()
