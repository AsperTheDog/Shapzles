extends Control

@export var text: String


func _ready():
	$PanelContainer/RichTextLabel.text = "[center]" + text


func changeText(newText: String):
	text = newText
	_ready()


func hideFooter():
	$RichTextLabel2.hide()
