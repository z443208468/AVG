extends VBoxContainer

var character_joined_text := "{character} 入场。"
var character_left_text := "{character} 退场。"
var all_character_left_text := "全部人物退场。"

@export var dot_image: Texture = null


func load_info(info:Dictionary) -> void:
	%Speaker.hide()

	match info.event_type:
		"Text":
			%Message.text = info['text']

			if not info.get('character', null) == null:
				%Speaker.text = info.character
				%Speaker.modulate = info.character_color
				%Speaker.show()

		"Character":
			match info.mode:
				"Join":
					%Message.text = '[i]' + character_joined_text.format(info)
				"Leave":
					if info.character == "All":
						%Message.text = '[i]' + all_character_left_text.format(info)
					else:
						%Message.text = '[i]' + character_left_text.format(info)

		"Choice":
			var choices_text: String = ""
			for choice: Dictionary in info['all_choices']:
				if not choice.visible:
					continue
				var choice_text: String = Dialogic.VAR.parse_variables(choice.text)
				if choice.disabled:
					choices_text += "- [i]({choice_text})[/i]\n".format({"choice_text":choice_text})

				elif choice_text == info['text']:
					choices_text += "- [b]{choice_text}[/b]\n".format({"choice_text":choice_text})

				else:
					choices_text += "- {choice_text}\n".format({"choice_text":choice_text})

			%Message.text = choices_text
