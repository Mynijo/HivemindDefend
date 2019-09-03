extends Node

var a_star_map : AStar

var max_map_size : Vector3

func _init():
    a_star_map = AStar.new()
    max_map_size = Vector3(1000,1000,1000)

func _input(event):
    if event.is_action_pressed("Debug_input"):
        var test = get_node_path(Vector3(7,2,2),Vector3(2,3,2))
        pass



func pos_to_id(var pos : Vector3) -> int:
    #return int(pos.x * 10000000 + pos.y * 1000 + pos.z)
    return int(pos.x * max_map_size.y * max_map_size.z  + pos.y * max_map_size.z + pos.z)

func get_node_path(startNode : Vector3, endNode2 : Vector3) -> PoolVector3Array:
    return a_star_map.get_point_path(pos_to_id(startNode),pos_to_id(endNode2))


func connect_nodes(node : Vector3, node2 : Vector3):
    var nodeId = pos_to_id(node)
    var node2Id =pos_to_id(node2)

    if not a_star_map.has_point(nodeId):
        a_star_map.add_point(nodeId, node)

    if not a_star_map.has_point(node2Id):
        a_star_map.add_point(node2Id, node2)

    a_star_map.connect_points(nodeId, node2Id)