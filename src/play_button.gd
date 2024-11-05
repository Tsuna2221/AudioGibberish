extends Button

func _process(delta: float) -> void:
	self.disabled = DialogManager.isDialogActive
