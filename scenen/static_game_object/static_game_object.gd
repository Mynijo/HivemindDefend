class_name class_StaticGameObject extends Spatial

export (bool) var transparent = false


func _ready():
    pass # Replace with function body.

func get_position() -> Vector3:
    return self.translation

func set_position(position : Vector3):
    self.translation = position