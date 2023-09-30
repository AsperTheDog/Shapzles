extends Control

enum DialType {
	LETTER,
	NUMBER
}

var letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
var numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9']


func _ready():
	$LetterDial.grab_focus()
	$LetterDial/VerticalContainer/Dial.set_meta("lstType", DialType.LETTER)
	$NumberDial/VerticalContainer/Dial.set_meta("lstType", DialType.NUMBER)
	$CountdownBar.max_value = Game.countdownSeconds
	$CountdownBar.value = Game.remainingSeconds


func _process(delta):
	countdownTick(delta)
	var focused: RichTextLabel = get_viewport().gui_get_focus_owner().get_node("VerticalContainer/Dial")
	if Input.is_action_just_pressed("ui_down"):
		onDialChanged(focused, focused.get_meta("lstType"), -1)
	elif Input.is_action_just_pressed("ui_up"):
		onDialChanged(focused, focused.get_meta("lstType"), 1)
	elif Input.is_action_just_pressed("Confirm"):
		pass


func onDialChanged(label: RichTextLabel, lstType: DialType, dir: int) -> void:
	var lst = letters if lstType == DialType.LETTER else numbers
	var newIdx = clamp(lst.find(label.text.lstrip("[center]")) + dir, 0, Game.maxSymbols - 1)
	label.text = "[center]" + lst[newIdx]


func countdownTick(delta):
	$CountdownBar/CountDown.text = "[center]" + Game.getStringFromCountdown()
	$CountdownBar.value = Game.remainingSeconds
