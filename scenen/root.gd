extends Spatial

var map : class_map
# Called when the node enters the scene tree for the first time.
func _ready():
    var class_map = resource_manager.get_resource("res://scenen/map/map.tscn")
    var map = class_map.instance() 
    map.gen_map_with_file()
    self.add_child(map)
    #save_load_manager.save_game()
    #save_load_manager.load_game()
    get_tree().get_root().print_stray_nodes()