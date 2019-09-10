extends Node

var a_star_map : AStar

var max_map_size : Vector3

func _init():
    a_star_map = AStar.new()
    max_map_size = Vector3(100,100,100)

func _input(event):
    if event.is_action_pressed("Debug_input"):
        var test = get_node_path(Vector3(2,3,4),Vector3(2,1,1))
        for node in test:
            print(node)
        pass

func pos_to_id(var pos : Vector3) -> int:
    #return int(pos.x * 10000000 + pos.y * 1000 + pos.z)
    return int(pos.x * max_map_size.y * max_map_size.z  + pos.y * max_map_size.z + pos.z)

func get_node_path(startNode : Vector3, endNode2 : Vector3) -> PoolVector3Array:
    if not a_star_map.has_point(pos_to_id(startNode)) or not a_star_map.has_point(pos_to_id(endNode2)):
        return PoolVector3Array()
    return a_star_map.get_point_path(pos_to_id(startNode),pos_to_id(endNode2))

func del_nodes(node : Vector3):
    for connected_node in a_star_map.get_point_connections(pos_to_id(node)):       
        disconnect_nodes_id(pos_to_id(node), connected_node)
    a_star_map.set_point_disabled(pos_to_id(node))

func disconnect_nodes(startNode : Vector3, endNode : Vector3):
    disconnect_nodes_id(pos_to_id(startNode), pos_to_id(endNode))
        
func disconnect_nodes_id(startNode_id : int, endNode_id : int):
    if a_star_map.has_point(startNode_id) and a_star_map.has_point(endNode_id):
        print("Disconnect points: " + String(startNode_id) + " </> " + String(endNode_id))
        a_star_map.disconnect_points(startNode_id,endNode_id)
    elif not a_star_map.has_point(startNode_id):
        print("Disconnect points faild: " + String(startNode_id) + " is not added")
    else:
        print("Disconnect points faild: " + String(endNode_id) + " is not added")
          
func connect_nodes(node : Vector3, node2 : Vector3, bidirectional : bool = true):
    var nodeId = pos_to_id(node)
    var node2Id =pos_to_id(node2)
    if not a_star_map.has_point(nodeId):
        a_star_map.add_point(nodeId, node)
    if not a_star_map.has_point(node2Id):
        a_star_map.add_point(node2Id, node2)
        
    if a_star_map.is_point_disabled(nodeId):
        a_star_map.set_point_disabled(nodeId, false)   
    if a_star_map.is_point_disabled(node2Id):
        a_star_map.set_point_disabled(node2Id, false)   

    a_star_map.connect_points(nodeId, node2Id, bidirectional)
