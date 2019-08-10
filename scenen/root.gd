extends Spatial

var map : class_map
# Called when the node enters the scene tree for the first time.
func _ready():
    var class_map = load("res://scenen/map/map.tscn")
    var map = class_map.instance() 
    map.gen_map_with_file()
    self.add_child(map)
