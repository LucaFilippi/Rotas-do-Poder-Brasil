class_name CityMap
extends Control

signal stop_clicked(id: int)
var sim: Simulation
var selected_stops: Array = []
var selected_line := -1
var zoom := 0.19
var offset := Vector2.ZERO
var dragging := false
var moved := false
var animation_time := 0.0
var redraw_time := 0.0

func _ready() -> void:
	clip_contents = true
	mouse_default_cursor_shape = Control.CURSOR_CROSS
	resized.connect(fit_map)
	fit_map()

func fit_map() -> void:
	if size.x < 1 or sim == null:
		return
	zoom = minf(size.x / 3900.0, size.y / 4000.0)
	offset = size / 2.0
	queue_redraw()

func screen_point(node: int) -> Vector2:
	return sim.geo.position(node) * zoom + offset

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				var before: Vector2 = (event.position - offset) / zoom
				zoom = clampf(zoom * (1.2 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.2), 0.06, 2.0)
				offset = event.position - before * zoom
				queue_redraw()
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			if event.pressed:
				dragging = true
				moved = false
			else:
				dragging = false
				if not moved and event.button_index == MOUSE_BUTTON_LEFT:
					var nearest := -1
					var distance := 18.0
					for stop in sim.geo.stops:
						var d: float = event.position.distance_to(screen_point(int(stop.node)))
						if d < distance:
							distance = d
							nearest = int(stop.id)
					if nearest >= 0:
						stop_clicked.emit(nearest)
	elif event is InputEventMouseMotion and dragging:
		if event.relative.length() > 1:
			moved = true
		offset += event.relative
		queue_redraw()
	accept_event()

func _process(delta: float) -> void:
	animation_time += delta
	redraw_time += delta
	if redraw_time > 0.12:
		redraw_time = 0.0
		queue_redraw()

func draw_route(path: Array, color: Color, width: float) -> void:
	if path.size() < 2:
		return
	var points := PackedVector2Array()
	for node in path:
		points.append(screen_point(int(node)))
	draw_polyline(points, color, width, true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101e2a"))
	if sim == null:
		return
	var font := ThemeDB.fallback_font
	for x in range(0, int(size.x), 80):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("142432"))
	for y in range(0, int(size.y), 80):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("142432"))
	var labels := 0
	for road in sim.geo.data.roads:
		var points := PackedVector2Array()
		var visible := false
		for node in road.nodes:
			var p := screen_point(int(node))
			points.append(p)
			visible = visible or Rect2(Vector2(-100, -100), size + Vector2(200, 200)).has_point(p)
		if not visible or points.size() < 2:
			continue
		var major: bool = road.kind in ["primary", "secondary", "tertiary", "trunk"]
		draw_polyline(points, Color("435565") if major else Color("2a3c4b"), 3.0 if major else 1.5, true)
		if major and not road.name.is_empty() and labels < 16 and road.nodes.size() > 6:
			draw_string(font, points[points.size() / 2] + Vector2(4, -5), road.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("8296a5"))
			labels += 1
	for line in sim.state.lines:
		var color := Color("57b6ab") if int(line.id) != selected_line else Color("f7bd65")
		draw_route(line.path, color, 3.5)
	var route := sim.geo.circuit(selected_stops)
	if not route.is_empty():
		draw_route(route.path, Color("ffcc75"), 4.0)
	for stop in sim.geo.stops:
		var p := screen_point(int(stop.node))
		var selected := selected_stops.has(int(stop.id))
		draw_circle(p, 7.0 if selected else 4.5, Color("ffd38b") if selected else Color("10222b"))
		draw_arc(p, 7.0 if selected else 4.5, 0, TAU, 16, Color("ffd38b") if selected else Color("80c7c2"), 1.5, true)
		if zoom > 0.24 or selected:
			draw_string(font, p + Vector2(8, 4), str(int(stop.id) + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("d5e5e8"))
	# Marcadores visuais; o fechamento econômico usa passos diários agregados.
	var available := int(sim.state.drivers)
	for line in sim.state.lines:
		var active := mini(int(line.buses), available)
		available -= active
		var path: Array = line.path
		for bus in mini(active, 6):
			if path.size() > 1:
				var index := fmod(animation_time * 3.0 + bus * 17.0, path.size() - 1)
				var p := screen_point(int(path[int(index)])).lerp(screen_point(int(path[int(index) + 1])), fmod(index, 1.0))
				draw_rect(Rect2(p - Vector2(4, 3), Vector2(8, 6)), Color("eaf5f4"))
	var bar_meters := 500.0
	draw_line(Vector2(25, size.y - 35), Vector2(25 + bar_meters * zoom, size.y - 35), Color("d0dedf"), 2)
	draw_string(font, Vector2(25, size.y - 44), "500 m", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a6b8c4"))
