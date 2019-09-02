extends Node

const SAVES_DIR = "res://saves"
const DEFAULT_SAVE_FILE = "savegame.save"

func _ready():
    pass # Replace with function body.

func save_game(save_file : String = DEFAULT_SAVE_FILE):
    save_file = SAVES_DIR + "/" + save_file
    var save_game = File.new()
    save_game.open(save_file, File.WRITE)
    var save_nodes = get_tree().get_nodes_in_group("persist")
    var node_data : Array = []
    for i in save_nodes:
        node_data.append(i.call("save"))

    save_game.store_line(to_json(node_data))
    save_game.close()


func load_game(save_file : String = DEFAULT_SAVE_FILE):
    save_file = SAVES_DIR + "/" + save_file
    var save_game = File.new()
    if not save_game.file_exists(save_file):
        return # Error! We don't have a save to load.

    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open(save_file, File.READ)

    var parsed_json = parse_json(save_game.get_as_text())

    for n in parsed_json:
        var new_object = get_node(n["path"])
        new_object.load_game(n["data"])
    save_game.close()
