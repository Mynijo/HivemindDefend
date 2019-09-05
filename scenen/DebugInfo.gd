extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_Button_pressed():
    var nodes : PoolVector3Array = pathfinding_manager.get_node_path(Vector3(7,2,2),Vector3(2,3,2))
    var label : Label = get_tree().get_root().get_node("/root/root/DebugInfo/Labels/PathNodesValue")
    var pathAsString = ""
    for node in nodes:
        pathAsString = pathAsString + String(node) + "\n"
    label.set_text(pathAsString)
