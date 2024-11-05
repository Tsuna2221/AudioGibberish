extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterTimer
@onready var audioPlayer = $AudioStreamPlayer

const MAX_WIDTH = 1920

var text = ""
var letterIndex = 0

var letterTime = 0.03
var spaceTime = 0.06
var punctuationTime = 0.3

var mainNode

var minPitch
var maxPitch
var emphasisPitch
var emphasisLetters

signal finishedDisplay()

func _ready():
	mainNode = get_tree().root.get_children()[1]
	
	var n_minPitch = mainNode.get_node("Pitch/MinPitch/Input")
	var n_maxPitch = mainNode.get_node("Pitch/MaxPitch/Input")
	var n_emphasisPitch = mainNode.get_node("Pitch/EmphasisPitch/Input")
	var n_emphasisLetters = mainNode.get_node("Pitch/EmphasisLetter/Input")
	var letterArray: Array[String]
	letterArray.assign(n_emphasisLetters.text.split(","))
	
	minPitch = float(n_minPitch.text)
	maxPitch = float(n_maxPitch.text)
	emphasisPitch = float(n_emphasisPitch.text)
	emphasisLetters = letterArray.map(func(letter): return letter.strip_edges(true, true))

func displayText(textToDisplay: String, speechSfx: AudioStream):
	text = textToDisplay
	label.text = textToDisplay
	audioPlayer.stream = speechSfx
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	label.text = ""
	_displayLetter()
	
func _displayLetter():
	label.text += text[letterIndex]
	letterIndex += 1
	
	if letterIndex >= text.length():
		finishedDisplay.emit()
		return
		
	match text[letterIndex]:
		"!", ".", ",", "?":
			timer.start(punctuationTime)
		" ":
			timer.start(spaceTime)
		_:
			timer.start(letterTime)
			
			var newAudioPlayer = audioPlayer.duplicate()
			newAudioPlayer.pitch_scale += randf_range(minPitch, maxPitch)
			if text[letterIndex] in emphasisLetters:
				newAudioPlayer.pitch_scale += emphasisPitch
			mainNode.add_child(newAudioPlayer)
			newAudioPlayer.play()
			await newAudioPlayer.finished
			newAudioPlayer.queue_free()
			
func _on_letter_timer_timeout() -> void:
	_displayLetter()
