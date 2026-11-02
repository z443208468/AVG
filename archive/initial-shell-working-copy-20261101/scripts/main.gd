extends Control
## 正式游戏外壳的基础候选；文本页仅用于开篇结构预览。
const SAVE_VERSION := 1
const CONTENT_VERSION := "opening-outline-01"
var pages: Array = []
var cursor := 0
var active := false
var history: Array[String] = []
var font_size := 26
var master_volume := 0.8
var body: VBoxContainer

func _ready() -> void:
	pages = JSON.parse_string(FileAccess.get_file_as_string("res://content/opening-preview.json"))
	var settings := ConfigFile.new()
	if settings.load("user://settings.cfg") == OK:
		font_size = clampi(int(settings.get_value("text", "size", 26)), 20, 38)
		master_volume = clampf(float(settings.get_value("audio", "master", 0.8)), 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	var background := ColorRect.new()
	background.color = Color("151e24")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 90)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 35)
	add_child(margin)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)
	menu()
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../docs/title-shell.png")
		get_tree().quit()
	if "--smoke" in OS.get_cmdline_user_args():
		call_deferred("smoke")

func clear() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()

func label(text: String, size: int = 26) -> void:
	var item := Label.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	body.add_child(item)

func button(text: String, callback: Callable, disabled: bool = false) -> void:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = 40
	item.disabled = disabled
	item.pressed.connect(callback)
	body.add_child(item)

func menu() -> void:
	clear()
	label("苍 岐", 58)
	label("苍山多歧路，谁识少年心", 24)
	button("开始游戏 · 开篇结构预览", new_game)
	button("继续游戏", func(): load_slot(0), not valid_slot(0))
	button("读取存档", func(): slots(false))
	button("鉴赏 · CG / 音乐", gallery)
	button("设置", settings_page)
	button("退出游戏", func(): get_tree().quit())
	label("开发候选｜开篇文字节选供结构讨论，正式图音与第一场演出待接入", 18)

func new_game() -> void:
	cursor = 0
	history.clear()
	active = true
	show_page()

func show_page() -> void:
	clear()
	var page: Dictionary = pages[cursor]
	label(str(page.title), 32)
	var text := RichTextLabel.new()
	text.text = str(page.text)
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", font_size)
	body.add_child(text)
	button("下一页" if cursor < pages.size() - 1 else "返回标题", advance)
	button("保存进度", func(): slots(true))
	button("回看已读文本", backlog)
	button("返回标题", menu)

func advance() -> void:
	history.append(str(pages[cursor].text))
	if cursor + 1 >= pages.size():
		active = false
		menu()
		return
	cursor += 1
	save_slot(0)
	show_page()

func save_path(slot: int) -> String:
	var prefix := "smoke-" if "--smoke" in OS.get_cmdline_user_args() else "slot-"
	return "user://%s%d.json" % [prefix, slot]

func read_slot(slot: int) -> Dictionary:
	if not FileAccess.file_exists(save_path(slot)):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path(slot)))
	if not data is Dictionary:
		return {}
	if data.get("version") != SAVE_VERSION or data.get("content") != CONTENT_VERSION:
		return {}
	var index = data.get("cursor", -1)
	if not (index is float or index is int) or index != int(index):
		return {}
	if int(index) < 0 or int(index) >= pages.size() or not data.get("history") is Array:
		return {}
	for entry in data.history:
		if not entry is String:
			return {}
	return data

func valid_slot(slot: int) -> bool:
	return not read_slot(slot).is_empty()

func save_slot(slot: int) -> bool:
	var file := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("无法写入存档")
		return false
	file.store_string(JSON.stringify({"version": SAVE_VERSION, "content": CONTENT_VERSION,
		"cursor": cursor, "history": history, "time": Time.get_datetime_string_from_system()}))
	file.close()
	return true

func load_slot(slot: int) -> void:
	var data := read_slot(slot)
	if data.is_empty():
		return
	cursor = int(data.cursor)
	history.assign(data.history)
	active = true
	show_page()

func slots(saving: bool) -> void:
	clear()
	label("保存进度" if saving else "读取进度", 32)
	for i in range(1, 4):
		var data := read_slot(i)
		var caption := "空" if data.is_empty() else "%s · %s" % [pages[int(data.cursor)].title, data.time]
		button("存档 %d · %s" % [i, caption], func():
			if saving:
				if save_slot(i):
					show_page()
			else:
				load_slot(i), not saving and data.is_empty())
	button("返回", show_page if active else menu)

func backlog() -> void:
	clear()
	label("已读回看", 32)
	var text := RichTextLabel.new()
	text.text = "\n\n".join(history) if not history.is_empty() else "尚无已读内容。"
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", font_size)
	body.add_child(text)
	button("返回剧情", show_page)

func gallery() -> void:
	clear()
	label("鉴赏", 36)
	label("CG 与音乐将在主线首次观看／收听后解锁。\n当前未安装正式图音包，没有可回放项目。")
	button("返回", menu)

func settings_page() -> void:
	clear()
	label("设置", 36)
	label("正文字号")
	var size := HSlider.new()
	size.min_value = 20
	size.max_value = 38
	size.step = 1
	size.value = font_size
	size.value_changed.connect(func(value): font_size = int(value); persist_settings())
	body.add_child(size)
	label("主音量（正式音频待接入）")
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.value = master_volume
	volume.value_changed.connect(func(value):
		master_volume = value
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
		persist_settings())
	body.add_child(volume)
	button("窗口 / 全屏", func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN))
	button("返回", menu)

func persist_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("text", "size", font_size)
	config.set_value("audio", "master", master_volume)
	config.save("user://settings.cfg")

func smoke() -> void:
	new_game()
	advance()
	assert(cursor == 1 and history.size() == 1)
	assert(save_slot(1))
	cursor = 0
	load_slot(1)
	assert(cursor == 1 and history.size() == 1)
	while active:
		advance()
	assert(not active)
	new_game()
	assert(cursor == 0 and history.is_empty())
	for slot in [0, 1]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path(slot)))
	print("SHELL_SMOKE_OK: start -> advance -> save -> restore -> end -> restart")
	get_tree().quit()
