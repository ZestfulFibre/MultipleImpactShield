class_name ShieldNextPass extends Shield

@export var base_expansion:float = 0.05
var expansion:float = 0


func _process(delta: float) -> void:
	var decayed_points:Array[Vector4] = _points.decay_points(delta, SHIELD_IMPACT_DECAY_SPEED)
	shield_appearance.material_override.next_pass.set("shader_parameter/impact_points", decayed_points)
	
	expansion = lerpf(expansion, base_expansion, delta)
	shield_appearance.material_override.next_pass.set("shader_parameter/extend_distance", expansion)


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	super._on_input_event(camera, event, event_position, normal, shape_idx)
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			expansion += base_expansion * 0.5
