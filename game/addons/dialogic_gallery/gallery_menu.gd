extends OverlayUI_Tab

signal selected(meta: TimelineMeta)

var cg_timeline_metas: Dictionary = {}

@export var TimelineMetaCardScene: PackedScene
@onready var GalleryGrid = $ScrollContainer/GridContainer
var dirty: bool = true

################################################################################
##								PUBLIC
################################################################################

func _event_visited(_event: DialogicEvent):
	
	if _event is DialogicTextEvent:
		dirty = true


func _open() -> void:
	if cg_timeline_metas.size() == 0 or dirty:
		Dialogic.History.load_visited_history()
		await draw()
		dirty = false
	show()
	if GalleryGrid.get_child_count() > 0:
		GalleryGrid.get_child(0).grab_focus.call_deferred()
	for card in GalleryGrid.get_children():
		if card.seen:
			card.grab_focus.call_deferred()
			break
	
################################################################################
##								PRIVATE
################################################################################

## 游戏自己的鉴赏条目放 content/gallery；examples/gallery 为示例，删除 examples 后自动为空。
const GALLERY_DIRS := ["res://content/gallery", "res://examples/gallery"]

func _load_timeline_meta_resources():
	cg_timeline_metas = {}
	for dir in GALLERY_DIRS:
		for file in ResourceLoader.list_directory(dir):
			if file.ends_with(".tres"):
				var meta: TimelineMeta = ResourceLoader.load(dir.path_join(file))
			
				if meta.timeline == null:
					push_warning("Timeline Meta Resource without timeline: %s" % file)
					continue
				if meta.timeline_type != TimelineMeta.TimelineType.CG:
					continue
				cg_timeline_metas[meta.timeline.get_identifier()]= meta
			
func draw() -> void:
	var tmp_scene = TimelineMetaCardScene.instantiate()
	await get_tree().process_frame
	GalleryGrid.columns = clamp(roundi(self.size.x / tmp_scene.size.x), 1, 10)
	tmp_scene.free()
	for child in GalleryGrid.get_children():
		child.queue_free()
	for meta in cg_timeline_metas.values():
		var card: TimelineMetaCard = TimelineMetaCardScene.instantiate()
		card.set_timeline_meta(meta)
		GalleryGrid.add_child(card)
		card.pressed.connect(selected.emit)
	
func _ready() -> void:
	_load_timeline_meta_resources()
	Dialogic.event_handled.connect(_event_visited)
	hide()
