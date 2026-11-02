@tool
extends DialogicLayoutLayer

## This layer displays text, but also has a  bunch of useful buttons for use in-game.

var overlay_ui: Control = null
var reading_ui_hidden := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		for button_name in {"QSave": KEY_F5, "QLoad": KEY_F9}:
			var key := InputEventKey.new()
			key.keycode = {"QSave": KEY_F5, "QLoad": KEY_F9}[button_name]
			var shortcut := Shortcut.new()
			shortcut.events = [key]
			get_node("Buttons/" + button_name).shortcut = shortcut
		Dialogic.Settings.connect_to_change("dialogue_font_size", _apply_dialogue_font_size)
		_apply_dialogue_font_size(Dialogic.Settings.get_setting("dialogue_font_size", 38))
	Dialogic.Inputs.auto_skip.toggled.connect(_on_auto_skip_toggled)
	Dialogic.Inputs.auto_advance.toggled.connect(_on_auto_advance_toggled)
	if get_tree().root.has_node("Menus"):
		overlay_ui = get_tree().root.get_node("Menus/GUILayer/OverlayUI")
		overlay_ui.visibility_changed.connect(_restore_reading_ui_for_menu)


#region TOOL BUTTONS
################################################################################

func _on_history_pressed() -> void:
	# Take a thumbnail.
	# This is a special case, because it's possible to navigate from the history to the save page directly.
	Dialogic.Save.take_thumbnail()

	Dialogic.History.open_history()


func _on_skip_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_skip.enabled = toggled_on
	Dialogic.Inputs.auto_advance.enabled_until_user_input = false

## Dialogic informs us that the autoskip state has changed
func _on_auto_skip_toggled(toggled_on: bool) -> void:
	%Skip.set_pressed_no_signal(toggled_on)


func _on_auto_toggled(toggled_on: bool) -> void:
	Dialogic.Inputs.auto_advance.enabled_until_user_input = toggled_on
	Dialogic.Inputs.auto_skip.enabled = false


## Dialogic informs us that the autoadvance state has changed
func _on_auto_advance_toggled(toggled_on: bool) -> void:
	%Auto.set_pressed_no_signal(toggled_on)


func _on_save_pressed() -> void:
	if overlay_ui:
		Dialogic.Save.take_thumbnail()
		overlay_ui.open_save_menu()


func _on_q_save_pressed() -> void:
	Dialogic.Save.save("slot_59")


func _on_q_load_pressed() -> void:
	if Dialogic.Save.has_slot("slot_59"):
		Dialogic.Save.autosave_enabled = true
		if overlay_ui:
			overlay_ui.get_node("%MainMenu").gallery_replay = false
		Dialogic.Save.load("slot_59")


func _on_options_pressed() -> void:
	if overlay_ui:
		# Take a thumbnail.
		# This is a special case, because it's possible to navigate from the options to the save page directly.
		Dialogic.Save.take_thumbnail()
		overlay_ui.open_options_menu()

#endregion

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("hide_reading_ui"):
		if reading_ui_hidden:
			_restore_reading_ui()
		elif (not Dialogic.paused and $TextboxBG.is_visible_in_tree()
				and Dialogic.current_state == DialogicGameHandler.States.IDLE):
			reading_ui_hidden = true
			Dialogic.paused = true
			$TextboxBG.hide()
			$Buttons.hide()
		get_viewport().set_input_as_handled()
		return
	if reading_ui_hidden:
		return
	if Input.is_action_just_pressed("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = true
	elif Input.is_action_just_released("skip_dialog"):
		Dialogic.Inputs.auto_skip.enabled = false


func _restore_reading_ui() -> void:
	if reading_ui_hidden:
		reading_ui_hidden = false
		$TextboxBG.show()
		$Buttons.show()
		Dialogic.paused = false
		Dialogic.Inputs.block_input()


func _restore_reading_ui_for_menu() -> void:
	if overlay_ui.visible:
		_restore_reading_ui()


## Font overrides reused from Dialogic's default VN textbox _apply_text_settings.
func _apply_dialogue_font_size(text_size: int) -> void:
	var dialog_text := $TextboxBG/DialogicNode_DialogText
	dialog_text.add_theme_font_size_override(&"normal_font_size", text_size)
	dialog_text.add_theme_font_size_override(&"bold_font_size", text_size)
	dialog_text.add_theme_font_size_override(&"italics_font_size", text_size)
	dialog_text.add_theme_font_size_override(&"bold_italics_font_size", text_size)
	dialog_text.add_theme_font_size_override(&"mono_font_size", text_size)
