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
	var path: Array = []
	# Ida via todos os pontos; volta via os mesmos pontos em ordem inversa.
	var itinerary := stop_ids.duplicate()
	for i in range(stop_ids.size() - 2, -1, -1):
		itinerary.append(stop_ids[i])
	var meters := 0.0
	for i in range(itinerary.size() - 1):
		var a := int(stops[int(itinerary[i])].node)
		var b := int(stops[int(itinerary[i + 1])].node)
		var segment := graph.get_id_path(a, b)
		if segment.is_empty():
			return {}
		for j in range(segment.size() - 1):
			meters += float(edges["%d:%d" % [segment[j], segment[j + 1]]])
		for j in range(segment.size()):
			if path.is_empty() or path.back() != segment[j]:
				path.append(segment[j])
	return {"path": path, "distance_km": meters / 1000.0}
