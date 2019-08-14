extends Node

var loaded_resources : Dictionary

func _ready():
    pass # Replace with function body.

func get_resource(path : String) -> Node:
    if not loaded_resources.has(path):
        loaded_resources[path] = load(path)
        print("Load: ", path)
    return loaded_resources.get(path)
