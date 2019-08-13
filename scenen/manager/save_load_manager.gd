extends Node

var default_save_file = "res://saves/save_file.json"

func _ready():
    pass # Replace with function body.

func save_game(Save_file : String = default_save_file ):
    var save_game = File.new()
    save_game.open("res://saves/savegame.save", File.WRITE)
    var save_nodes = get_tree().get_nodes_in_group("persist")
    var node_data : Array = []
    for i in save_nodes:
        node_data.append(i.call("save"))
    
    save_game.store_line(to_json(node_data))
    save_game.close()
    


func load_game(Save_file : String = default_save_file ):
    var save_game = File.new()
    if not save_game.file_exists("res://saves/savegame.save"):
        return # Error! We don't have a save to load.

    # We need to revert the game state so we're not cloning objects
    # during loading. This will vary wildly depending on the needs of a
    # project, so take care with this step.
    # For our example, we will accomplish this by deleting saveable objects.
    var save_nodes = get_tree().get_nodes_in_group("persist")
    for i in save_nodes:
        i.free()

    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open("res://saves/savegame.save", File.READ)

    var parsed_json = parse_json(save_game.get_as_text())
    
    for n in parsed_json:        
        var new_object = resource_manager.get_resource(n["filename"]).instance()   
        new_object.load_game(n["data"])
        get_node(n["parent"]).add_child(new_object)
    save_game.close()
