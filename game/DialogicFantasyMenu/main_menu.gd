extends CanvasLayer

## Script that manages the main menu buttons

## A tween that controls the pitch of the main menu button sounds
## These sounds get higher pitched, when buttons are hovered in quick succession
var main_menu_button_pitch_tween: Tween
var gallery_replay := false

@export var beginning_timeline := "FrameworkExample"

func _ready() -> void:
	Dialogic.History.load_visited_history()
	## Connect buttons to hovered, unhovered and pressed
	for button: Node in %MainMenuButtons.get_children():
		if not button is Button:
			continue
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
		button.pressed.connect(_on_button_pressed.bind(button))

	open()

	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	Dialogic.Save.saved.connect(_on_progress_saved)


func open() -> void:
	gallery_replay = false
	show()

	## When there is a save to continue from, show the Continue button
	## and make the Continue button special, instead of the start one.
	%Continue.visible = not Dialogic.Save.get_latest_slot().is_empty()
	if %Continue.visible:
		%Continue.grab_focus()
		%Start.theme_type_variation = ""
		%Start.flat = true
	else:
		%Start.grab_focus()
		%Start.theme_type_variation = "SpecialButton"
		%Start.flat = false

	## Don't show the Quit button on the web
	%Quit.visible = !OS.has_feature("web")


func _on_dialogic_signal_event(arg: Variant) -> void:
	if arg == "GAME_END":
		get_viewport().set_input_as_handled()
		Dialogic.History.save_visited_history()
		Dialogic.clear()
		## Assuming that the end of the game was reached,
		## We don't want to keep suggestion to "Continue" from the last save.
		if not gallery_replay:
			Dialogic.Save.set_latest_slot("")
		open.call_deferred()


#region BUTTON FUNCTIONALITY
################################################################################

func _on_start_pressed() -> void:
	Dialogic.Save.autosave_enabled = true
	Dialogic.start(beginning_timeline)
	hide()


func _on_continue_pressed() -> void:
	Dialogic.Save.autosave_enabled = true
	Dialogic.Save.load(Dialogic.Save.get_latest_slot())
	hide()


func _on_load_pressed() -> void:
	%OverlayUI.open_load_menu()


func _on_options_pressed() -> void:
	%OverlayUI.open_options_menu()


func _on_about_pressed() -> void:
	%OverlayUI.open_about_menu()


func _on_help_pressed() -> void:
	%OverlayUI.open_help_menu()


func _on_gallery_pressed() -> void:
	%OverlayUI.open_tab(%GalleryTab)


func _on_gallery_selected(meta: TimelineMeta) -> void:
	gallery_replay = true
	Dialogic.Save.autosave_enabled = false
	hide()
	await %OverlayUI.close().finished
	Dialogic.start(meta.timeline)


func _on_quit_pressed() -> void:
	get_tree().quit()

#endregion


#region BUTTON HOVER/UNHOVER
################################################################################

func _on_button_hovered(button:Button) -> void:
	## Hover Animation
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE * 1.1, 0.2)

	## Hover sound
	%ButtonHoverSound.play()


func _on_button_unhovered(button:Button) -> void:
	## Hover Ended Animation
	var tween := button.create_tween()
	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE, 0.2)


func _on_main_menu_button_sound_finished() -> void:
	## Tween the button pitch to increase and then decrease after a second.
	## As this get's interrupted by following hover sounds,
	##  the pitch can increase for a while
	if main_menu_button_pitch_tween:
		main_menu_button_pitch_tween.kill()

	main_menu_button_pitch_tween = create_tween()

	## First increase the pitch
	main_menu_button_pitch_tween.tween_property(
		%ButtonHoverSound, "pitch_scale",
		lerp(%ButtonHoverSound.pitch_scale, 1.3, 0.1), 0.3)
	## Then decrease it
	main_menu_button_pitch_tween.tween_property(
		%ButtonHoverSound, "pitch_scale", 0.6, 2)


func _on_button_pressed(button: Button) -> void:
	%ButtonPressedSound.play()

#endregion


func _on_progress_saved(info: Dictionary) -> void:
	var label := "存档 " + str(info.slot_name.trim_prefix("slot_").to_int() + 1)
	if info.slot_name == "slot_58":
		label = "自动存档"
	elif info.slot_name == "slot_59":
		label = "快捷存档"
	var location: String = Dialogic.current_timeline.get_identifier()
	Dialogic.Save.set_slot_info(info.slot_name, {
		"name": label + " · " + location,
		"date": Time.get_datetime_dict_from_system(),
		"location": location,
		"event_index": Dialogic.current_event_idx,
	})
