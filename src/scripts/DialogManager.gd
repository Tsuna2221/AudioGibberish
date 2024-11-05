extends Node

@onready var textBoxScene = preload("res://src/text_box.tscn")

var dialogLines: Array[String] = []
var currentLineIndex = 0

var textBox
var textBoxPosition: Vector2

var sfx: AudioStream

var isDialogActive = false
var canAdvanceLine = false

var currentBox = null

func _ready() -> void:
	var file = FileAccess.open(OS.get_executable_path().get_base_dir()+'/audio.wav', FileAccess.READ)
	var sound = AudioStreamWAV.new()
	
	var buffer = file.get_buffer(file.get_length())
	file.close()
	
	sound.format = 1
	sound.data = buffer
	sound.mix_rate = 48000
	sound.stereo = true
	
	DialogManager.sfx = sound


func startDialog(position: Vector2, lines: Array[String]):
	if isDialogActive:
		return
		
	dialogLines = lines
	textBoxPosition = position
	
	_showTextBox()
	
	isDialogActive = true
	
func _showTextBox():
	var mainNode = get_tree().root.get_children()[1]
	
	textBox = textBoxScene.instantiate()
	textBox.letterTime = float(mainNode.letterTime.text)
	textBox.spaceTime = float(mainNode.spaceTime.text)
	textBox.punctuationTime = float(mainNode.punctuationTime.text)
	
	textBox.finishedDisplay.connect(_on_text_box_finished_displaying)
	get_tree().root.get_children()[1].add_child(textBox)
	textBox.global_position = textBoxPosition
	textBox.displayText(dialogLines[currentLineIndex], sfx)
	
	currentBox = textBox
	canAdvanceLine = false
	
func _on_text_box_finished_displaying():
	canAdvanceLine = true
	
func handleNext():
	if(is_instance_valid(textBox)):
		textBox.queue_free()
		
		currentLineIndex += 1
		
		if currentLineIndex >= dialogLines.size():
			isDialogActive = false
			currentLineIndex = 0
			
			return
			
		_showTextBox()

	
func _unhandled_input(event: InputEvent):
	if(
		event.is_action_pressed("ui_accept") &&
		isDialogActive &&
		canAdvanceLine
	):
		handleNext()
