extends Node

var maxSymbols: int = 6

var countdownSeconds: int = 300
@onready var remainingSeconds = countdownSeconds

var symbolData: Array = preload("res://Symbols/symbolTable.json").data


func _process(delta):
	countdownTick(delta)


func countdownTick(delta):
	remainingSeconds = max(0, remainingSeconds - delta)
	var mins = int(remainingSeconds) / 60
	var seconds = int(remainingSeconds) % 60


func getStringFromCountdown():
	var mins = int(remainingSeconds) / 60
	var seconds = int(remainingSeconds) % 60
	return ("%02d" % mins) + ":" + ("%02d" % seconds)
