@tool
extends Resource
class_name TimelineMeta
enum TimelineType {NORMAL, CG}

@export var timeline: DialogicTimeline
@export var timeline_type: TimelineType = TimelineType.NORMAL
@export var user_label: String
@export var thumbnail: CompressedTexture2D
@export var dev_description: String

func _get_extension() -> String:
	return "tres"

func _get_resource_name() -> String:
	return "TimelineMeta"
