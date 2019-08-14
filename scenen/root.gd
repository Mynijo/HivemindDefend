extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
    $Map.gen_map_with_file()
