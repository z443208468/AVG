extends Node
## Connect the official Pong scene's result to Dialogic's existing Call event.

func play_pong() -> void:
	Dialogic.Text.hide_textbox(true)
	var result: String = await Dialogic.Backgrounds.get_background_node().finished
	Dialogic.VAR.set_variable("PongResult", result)
	Dialogic.Text.show_textbox(true)
