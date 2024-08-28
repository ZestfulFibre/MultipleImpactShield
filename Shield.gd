class_name Shield extends Area3D

const SHIELD_IMPACT_DECAY_SPEED:float = 1

@export var shield_appearance:MeshInstance3D
# note that the size of the buffer created here must match the impacts_tracked const in the shader
# this can be freely changed however if you want to support more than 16 simultaneous impacts
var _points:PointBuffer = PointBuffer.new(16)


func _ready() -> void:
	# i do this here so that shield nodes that share this material dont all react to impacts on one shield
	# unfortunately I can't define instance uniform arrays in the Godot shader language
	shield_appearance.material_override = shield_appearance.material_override.duplicate()


func _process(delta: float) -> void:
	var decayed_points:Array[Vector4] = _points.decay_points(delta, SHIELD_IMPACT_DECAY_SPEED)
	shield_appearance.material_override.set("shader_parameter/impact_points", decayed_points)


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# note that due to the nature of shader taking information from collision points,
	# this works great on any shape, even a custom mesh
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			_points.push(to_local(event_position))

# the below is just a data structure to make handling impacts simpler
# it automatically removes the oldest impact information when new impacts are added
# and cleanly handles the decay of all tracked impacts when decay_points is called

class PointBuffer:
	var _buffer_index:int = 0
	var _points:Array[Vector4]
	
	func _init(buffer_size:int) -> void:
		_points.resize(buffer_size)
	
	func push(point:Vector3) -> void:
		_points[_buffer_index] = Vector4(point.x, point.y, point.z, 1.0)
		_buffer_index += 1
		if _buffer_index >= _points.size():
			_buffer_index = 0

	func decay_points(delta:float, decay_speed:float) -> Array[Vector4]:
		var new_points:Array[Vector4]
		for point in _points:
			new_points.append(Vector4(point.x, point.y, point.z, clamp(point.w - decay_speed * delta, 0, 1)))
		_points = new_points
		
		return _points
