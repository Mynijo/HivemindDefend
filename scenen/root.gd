extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
    var strat_time = OS.get_ticks_msec()

    $Map.gen_map_with_file()

    var map_gen_time = OS.get_ticks_msec() -strat_time
    print("Gen Map:       ",map_gen_time / 1000.0, "Sec")

    save_load_manager.save_game()
    var map_save_time = OS.get_ticks_msec() -map_gen_time
    print("save_game:     ",map_save_time / 1000.0, "Sec")

    save_load_manager.load_game()
    var map_load_time = OS.get_ticks_msec() -map_save_time
    print("load_game:    ",map_load_time / 1000.0, "Sec")
    #get_tree().get_root().print_stray_nodes()
