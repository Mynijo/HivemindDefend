extends Node

var loaded_resources : Dictionary

func _ready():
    pass # Replace with function body.

func get_resource(path : String) -> Node:
    if loaded_resources.has(path):        
        return loaded_resources.get(path)
    else:
        loaded_resources[path] = load(path)    
        return get_resource(path)
