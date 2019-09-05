extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var path_from : Vector3 = Vector3(7,2,2)
var path_to : Vector3 = Vector3(2,3,2)

# Called when the node enters the scene tree for the first time.
func _ready():
    $Labels/PathNodes.text = "PathNodes: " + str(path_from) + " -> " + str(path_to)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_Button_pressed():
    var nodes : PoolVector3Array = pathfinding_manager.get_node_path(self.path_from, self.path_to)
    var label : Label = get_tree().get_root().get_node("/root/root/DebugInfo/Labels/PathNodesValue")
    var pathAsString = ""
    var geom = get_tree().get_root().get_node("/root/root/PathLine")
    geom.clear()
    geom.begin(2)
    for node in nodes:
        pathAsString = pathAsString + String(node) + "\n"
        geom.add_vertex(node * Vector3(1, -1, 1))
    geom.end()
    label.set_text(pathAsString)
