extends Node2D

@onready var stream = preload("res://src/beeps/NOOT 3.wav")

@onready var inputBox = $SpeechInput/TextEdit

@onready var letterTime = $Options/LetterTime/Label
@onready var spaceTime = $Options/SpaceTime/Label
@onready var punctuationTime = $Options/PunctuationTime/Label

func _on_button_button_down() -> void:
	var inputText: String = inputBox.text
	var splitText = inputText.split("\n")
	
	DialogManager.isDialogActive = false
	DialogManager.startDialog(Vector2(DisplayServer.screen_get_size().x / 2, 300), splitText)

func _on_next_button_button_down() -> void:
	DialogManager.handleNext()
