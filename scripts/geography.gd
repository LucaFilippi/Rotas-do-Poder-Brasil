class_name Geography
extends RefCounted

var data: Dictionary
var graph := AStar2D.new()
var stops: Array
var edges := {}

func _init(path: String = "res://data/campinas/graph.json") -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or parsed.get("schema_version") != 1:
		return
	data = parsed
	stops = data.stops
	for key in data.points:
		var p = data.points[key]
		graph.add_point(int(key), Vector2(p[0], p[1]))
	for edge in data.edges:
		var a := int(edge[0])
		var b := int(edge[1])
		graph.connect_points(a, b, false)
		edges["%d:%d" % [a, b]] = float(edge[2])

func position(id: int) -> Vector2:
	return graph.get_point_position(id)

func circuit(stop_ids: Array) -> Dictionary:
	if stop_ids.size() < 2:
		return {}
	var unique := {}
	for id in stop_ids:
		if not (id is int or id is float) or not is_finite(float(id)) or float(id) != floor(float(id)) or int(id) < 0 or int(id) >= stops.size() or unique.has(int(id)):
			return {}
		unique[int(id)] = true
	var outbound := _route_between(stop_ids)
	var reversed_stops := stop_ids.duplicate()
	reversed_stops.reverse()
	var inbound := _route_between(reversed_stops)
	if outbound.is_empty() or inbound.is_empty():
		return {}
	var path: Array = outbound.path.duplicate()
	for node in inbound.path:
		if path.is_empty() or path.back() != node:
			path.append(node)
	return {"path": path, "outbound_path": outbound.path, "return_path": inbound.path,
		"outbound_distance_km": outbound.distance_km, "return_distance_km": inbound.distance_km,
		"distance_km": outbound.distance_km + inbound.distance_km}

func _route_between(sequence: Array) -> Dictionary:
	var path: Array = []
	var meters := 0.0
	for i in range(sequence.size() - 1):
		var a := int(stops[int(sequence[i])].node)
		var b := int(stops[int(sequence[i + 1])].node)
		var segment := graph.get_id_path(a, b)
		if segment.is_empty():
			return {}
		for j in range(segment.size() - 1):
			meters += float(edges["%d:%d" % [segment[j], segment[j + 1]]])
		for node in segment:
			if path.is_empty() or path.back() != node:
				path.append(node)
	return {"path": path, "distance_km": meters / 1000.0}
