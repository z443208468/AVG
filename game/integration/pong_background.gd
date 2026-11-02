extends DialogicBackground
## Sample-specific adapter for Godot's official 2d/pong demo.
## State is stored by Dialogic Backgrounds in the existing dialogue save.

signal finished(result: String)

func _ready() -> void:
	$Pong/LeftWall.area_entered.connect(_on_goal.bind("right"))
	$Pong/RightWall.area_entered.connect(_on_goal.bind("left"))

func _update_background(_argument: String, _time: float) -> void:
	viewport_container.stretch = false
	viewport.size = Vector2i(640, 400)
	viewport_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	viewport_container.size = Vector2(640, 400)
	viewport_container.scale = Vector2(2, 2)
	viewport_container.position = Vector2(320, 80)
	$Pong/Left._screen_size_y = 400
	$Pong/Right._screen_size_y = 400

func _on_goal(area: Area2D, result: String) -> void:
	if area.name == "Ball":
		_finish.call_deferred(result)

func _finish(result: String) -> void:
	$Pong.process_mode = Node.PROCESS_MODE_DISABLED
	finished.emit(result)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_minigame"):
		get_viewport().set_input_as_handled()
		_finish("cancel")

func _get_state() -> Dictionary:
	return {
		"ball_position": $Pong/Ball.position,
		"ball_direction": $Pong/Ball.direction,
		"ball_speed": $Pong/Ball._speed,
		"left_position": $Pong/Left.position,
		"right_position": $Pong/Right.position,
	}

func _load_state(state: Dictionary) -> void:
	$Pong/Ball.position = state.ball_position
	$Pong/Ball.direction = state.ball_direction
	$Pong/Ball._speed = state.ball_speed
	$Pong/Left.position = state.left_position
	$Pong/Right.position = state.right_position
