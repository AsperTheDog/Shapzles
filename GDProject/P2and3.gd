extends Control


func _process(delta):
	countdownTick(delta)


func countdownTick(delta):
	$CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$CountdownBar.value = Game.remainingSeconds
