extends Control

var sim: Simulation
var store: SaveStore
var map: CityMap
var side: VBoxContainer
var metrics: Array[Label] = []
var status: Label
var day_label: Label
var speed := 0
var accumulator := 0.0
var tab := "Mapa"
var editing_id := -1
var draft: Array = []
var draft_name := "Nova linha"
var draft_buses := 1
var slot := 1
var in_game := false
const GREEN = Color("69d9bc")
const MUTED = Color("8fa7b7")

func _ready() -> void:
	set_theme(build_theme())
	sim = Simulation.new()
	store = SaveStore.new()
	show_menu()

func build_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 16
	t.set_color("font_color", "Label", Color("e5edf0"))
	for type in ["Button", "OptionButton", "LineEdit", "SpinBox"]:
		for style in ["normal", "hover", "pressed", "focus", "read_only"]:
			var box := StyleBoxFlat.new()
			box.bg_color = Color("203e4b") if style in ["hover", "pressed"] else Color("152b39")
			box.set_corner_radius_all(7)
			box.content_margin_left = 14
			box.content_margin_right = 14
			box.content_margin_top = 10
			box.content_margin_bottom = 10
			t.set_stylebox(style, type, box)
	t.set_constant("separation", "VBoxContainer", 12)
	t.set_constant("separation", "HBoxContainer", 12)
	return t

func wipe() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func label_at(parent: Node, text: String, font_size: int = 16, color: Color = Color("e5edf0")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func button_at(parent: Node, text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func box_at(parent: Node, vertical: bool = true) -> BoxContainer:
	var box: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	parent.add_child(box)
	return box

func money(cents: int) -> String:
	var raw := str(absi(cents) / 100)
	var grouped := ""
	for i in raw.length():
		if i > 0 and (raw.length() - i) % 3 == 0:
			grouped += "."
		grouped += raw[i]
	return ("−" if cents < 0 else "") + "R$ " + grouped + ",%02d" % (absi(cents) % 100)

func margin_root() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	return margin

func show_menu() -> void:
	in_game = false
	speed = 0
	wipe()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = 650
	center.add_child(col)
	label_at(col, "SIMULAÇÃO • GESTÃO PÚBLICA • TRANSPORTES", 14, GREEN)
	label_at(col, "ROTAS DO PODER", 52)
	label_at(col, "BRASIL", 32, GREEN)
	label_at(col, "Uma cidade. Muitas escolhas. Cada viagem conta.", 20, MUTED)
	col.add_child(HSeparator.new())
	label_at(col, "FASE 1  /  PROTÓTIPO MUNICIPAL", 14, GREEN)
	label_at(col, "Crie sua empresa municipal, conecte Campinas e equilibre\nqualidade do serviço com sustentabilidade financeira.", 18)
	button_at(col, "Nova empresa  →", show_city_selection)
	var load_row := box_at(col, false)
	add_slot_picker(load_row)
	button_at(load_row, "Carregar partida", func():
		if store.load_game(sim, slot):
			show_dashboard()
		else:
			show_message(store.last_error))
	button_at(col, "Sair", func(): get_tree().quit())
	label_at(col, "Campinas / SP • grafo viário real • funcionamento offline\nParâmetros econômicos fictícios.", 14, MUTED)

func show_message(text: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = "Rotas do Poder"
	add_child(dialog)
	dialog.popup_centered(Vector2i(520, 160))
	dialog.confirmed.connect(dialog.queue_free)

func show_city_selection() -> void:
	wipe()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = 700
	center.add_child(col)
	label_at(col, "01 / ESCOLHA SUA CIDADE", 15, GREEN)
	label_at(col, "Campinas, São Paulo", 38)
	label_at(col, "Cidade de validação do protótipo • código IBGE 3509502", 17, MUTED)
	label_at(col, "Mapa: recorte central de aproximadamente 3 × 3 km.\n%d pontos sugeridos sobre ruas reais, com ida e volta roteadas.\nA população total e a demanda oficial não estão incorporadas.\nOutras cidades serão adicionadas na expansão geográfica." % sim.geo.stops.size(), 18)
	label_at(col, "Capital inicial: " + money(int(sim.balance.initial_cash)) + "\nFrota e equipe: comece comprando um ônibus e contratando um motorista.", 18, GREEN)
	var name_input := LineEdit.new()
	name_input.text = "Empresa Municipal de Campinas"
	name_input.max_length = 60
	col.add_child(name_input)
	button_at(col, "Criar empresa e abrir mapa  →", func():
		sim.new_game(name_input.text if not name_input.text.strip_edges().is_empty() else "Empresa Municipal de Campinas")
		draft.clear()
		editing_id = -1
		tab = "Mapa"
		show_dashboard())
	button_at(col, "Voltar", show_menu)

func add_slot_picker(parent: Node) -> void:
	var pick := OptionButton.new()
	for i in range(1, 4):
		pick.add_item("Partida %d" % i, i)
	pick.add_item("Automático", 0)
	pick.select(slot - 1 if slot > 0 else 3)
	pick.item_selected.connect(func(index: int): slot = pick.get_item_id(index))
	parent.add_child(pick)

func show_dashboard() -> void:
	wipe()
	in_game = true
	speed = 0
	accumulator = 0.0
	metrics.clear()
	var root := box_at(margin_root())
	var header := box_at(root, false)
	label_at(header, "RP / BRASIL", 22, GREEN).custom_minimum_size.x = 180
	var title := label_at(header, sim.state.company + "\nCAMPINAS • SP  /  SECRETARIA MUNICIPAL", 17)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	day_label = label_at(header, "", 16, MUTED)
	day_label.custom_minimum_size.x = 205
	button_at(header, "Menu", func():
		speed = 0
		var dialog := ConfirmationDialog.new()
		dialog.dialog_text = "Voltar ao menu? Salve suas decisões antes de sair.\nO automático guarda o último fechamento diário."
		add_child(dialog)
		dialog.confirmed.connect(show_menu)
		dialog.popup_centered())
	var strip := box_at(root, false)
	for metric in ["CAIXA", "RECEITA / DIA", "CUSTO / DIA", "RESULTADO / DIA", "SATISFAÇÃO"]:
		var cell := box_at(strip)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_at(cell, metric, 12, MUTED)
		metrics.append(label_at(cell, "—", 22))
	var body := box_at(root, false)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var nav := box_at(body)
	nav.custom_minimum_size.x = 165
	label_at(nav, "OPERAÇÃO", 12, MUTED)
	for item in ["Mapa", "Linhas", "Frota", "Equipe", "Tarifas", "Finanças", "Partidas"]:
		button_at(nav, item, func():
			tab = item
			render_side())
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav.add_child(spacer)
	button_at(nav, "Enquadrar mapa", func(): map.fit_map())
	label_at(nav, "FASE 1\nValores fictícios\nSimulação offline", 12, MUTED)
	var map_col := box_at(body)
	map_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var toolbar := box_at(map_col, false)
	label_at(toolbar, "CAMPINAS / CENTRO", 14, GREEN).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_at(toolbar, "Arraste para mover • roda para zoom", 12, MUTED).custom_minimum_size.x = 235
	map = CityMap.new()
	map.sim = sim
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map.custom_minimum_size = Vector2(300, 300)
	map_col.add_child(map)
	map.stop_clicked.connect(on_stop)
	var attribution := LinkButton.new()
	attribution.text = "© OpenStreetMap contributors • ODbL  |  Pontos e demanda estimados"
	attribution.add_theme_font_size_override("font_size", 12)
	attribution.pressed.connect(func(): OS.shell_open("https://www.openstreetmap.org/copyright"))
	map_col.add_child(attribution)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.x = 345
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	side = VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(side)
	var footer := box_at(root, false)
	status = label_at(footer, "Compre um ônibus, contrate um motorista e crie sua primeira linha.", 14, MUTED)
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var speeds := OptionButton.new()
	for value in [0, 1, 2, 5, 10]:
		speeds.add_item("Pausado" if value == 0 else "%dx" % value, value)
	speeds.item_selected.connect(func(index: int): speed = speeds.get_item_id(index))
	footer.add_child(speeds)
	button_at(footer, "Avançar 1 dia →", daily_step)
	render_side()
	refresh()

func refresh() -> void:
	var report := sim.preview()
	var shown: Dictionary = sim.state.history.back() if not sim.state.history.is_empty() else report
	metrics[0].text = money(int(sim.state.cash))
	metrics[0].modulate = Color("ff9b91") if sim.state.cash < 0 else Color.WHITE
	metrics[1].text = money(int(shown.revenue))
	metrics[2].text = money(int(shown.cost))
	metrics[3].text = money(int(shown.operating_result))
	metrics[3].modulate = GREEN if shown.operating_result >= 0 else Color("ff9b91")
	metrics[4].text = "%d%%" % int(sim.state.satisfaction)
	var date := Time.get_date_string_from_unix_time(1767225600 + int(sim.state.day) * 86400)
	day_label.text = "%s\nDia %d • jornada de 8 h" % [date, int(sim.state.day)]
	map.selected_stops = draft.duplicate()
	map.selected_line = editing_id
	map.queue_redraw()

func daily_step() -> void:
	var result := sim.advance_day()
	var saved := store.save_game(sim, 0)
	status.text = "%d passageiros • %d viagens sem atendimento • %s" % [int(result.passengers), int(result.unserved), "automático salvo" if saved else store.last_error]
	refresh()
	if tab in ["Finanças", "Frota", "Mapa"]:
		render_side()

func _process(delta: float) -> void:
	if not in_game or speed == 0:
		return
	accumulator += delta * speed
	while accumulator >= 4.0:
		accumulator -= 4.0
		daily_step()

func on_stop(id: int) -> void:
	if tab != "Linhas":
		tab = "Linhas"
	if draft.has(id):
		draft.erase(id)
	else:
		draft.append(id)
	render_side()
	refresh()

func line_editor(line: Dictionary) -> void:
	editing_id = int(line.id)
	draft = line.stops.duplicate()
	draft_name = line.name
	draft_buses = int(line.buses)
	render_side()
	refresh()

func render_side() -> void:
	for child in side.get_children():
		side.remove_child(child)
		child.queue_free()
	label_at(side, tab.to_upper(), 14, GREEN)
	match tab:
		"Mapa":
			label_at(side, "Sua rede começa aqui", 26)
			label_at(side, "1. Compre ônibus em Frota.\n2. Contrate motoristas em Equipe.\n3. Clique em pontos para desenhar uma linha.\n4. Aloque ônibus e avance o dia.", 17)
			label_at(side, "O mapa mostra ruas reais. Os círculos são pontos sugeridos; clique para definir a ordem de atendimento. A volta também respeita o sentido viário.", 16, MUTED)
			var p := sim.preview()
			label_at(side, "PRÓXIMO FECHAMENTO", 12, GREEN)
			label_at(side, "%d ônibus em operação\n%d passageiros previstos\n%d viagens não atendidas\nResultado: %s" % [int(p.active_buses), int(p.passengers), int(p.unserved), money(int(p.operating_result))], 18)
			label_at(side, "Receita, custo e resultado no topo exibem o último dia fechado; antes do primeiro dia são projeções.", 13, MUTED)
		"Linhas":
			render_lines()
		"Frota":
			label_at(side, "%d ônibus" % sim.state.buses.size(), 26)
			label_at(side, "Convencional Urbano 75\n75 passageiros • vida útil: 10 anos\nModelo fictício • operação a 20 km/h", 16, MUTED)
			button_at(side, "Comprar • " + money(int(sim.balance.bus_price)), func():
				status.text = "Ônibus adquirido. Aloque-o em Linhas." if sim.buy_bus() else sim.last_error
				refresh()
				render_side())
			for bus in sim.state.buses:
				label_at(side, "BUS %03d  •  %.1f km\n%d dias • ativo %s" % [int(bus.id), float(bus.km), int(bus.age_days), money(int(bus.book_value))], 16)
		"Equipe":
			label_at(side, "%d motoristas" % int(sim.state.drivers), 26)
			label_at(side, "Jornada simplificada: 8 horas por dia.\nCada ônibus ativo precisa de um motorista.\nAlocação na ordem das linhas da lista.", 16, MUTED)
			label_at(side, "Salário diário por motorista: " + money(int(sim.balance.driver_daily_salary)), 17)
			button_at(side, "Contratar • " + money(int(sim.balance.hiring_cost)), func():
				status.text = "Motorista contratado." if sim.hire_driver() else sim.last_error
				refresh()
				render_side())
			label_at(side, "Salários são pagos mesmo sem linha em operação. A contratação é um desembolso de transição separado do fechamento diário.", 14, MUTED)
		"Tarifas":
			label_at(side, "Preço de cada viagem", 26)
			var fare := SpinBox.new()
			fare.min_value = 0
			fare.max_value = 50
			fare.step = 0.10
			fare.prefix = "R$ "
			fare.value = float(sim.state.fare) / 100.0
			side.add_child(fare)
			var projection := label_at(side, "", 17)
			var project := func():
				var old: int = int(sim.state.fare)
				sim.state.fare = int(round(fare.value * 100))
				var p := sim.preview()
				sim.state.fare = old
				projection.text = "PREVISÃO / DIA\n%d passageiros\nReceita: %s\nResultado: %s\nSatisfação: %.1f%%" % [int(p.passengers), money(int(p.revenue)), money(int(p.operating_result)), float(p.satisfaction)]
			fare.value_changed.connect(func(_v: float): project.call())
			project.call()
			button_at(side, "Aplicar tarifa", func():
				sim.set_fare(int(round(fare.value * 100)))
				status.text = "Tarifa aplicada. A demanda será recalculada no próximo dia."
				refresh())
			label_at(side, "Tarifas maiores reduzem a procura e a acessibilidade; tarifa zero elimina a receita. A previsão usa o mesmo modelo da simulação.", 15, MUTED)
		"Finanças":
			render_finances()
		"Partidas":
			label_at(side, "Sua carreira", 26)
			add_slot_picker(side)
			button_at(side, "Salvar neste espaço", func(): status.text = "Partida salva." if store.save_game(sim, slot) else store.last_error)
			button_at(side, "Carregar deste espaço", func():
				if store.load_game(sim, slot):
					draft.clear()
					editing_id = -1
					show_dashboard()
				else:
					status.text = store.last_error)
			label_at(side, "Três partidas manuais e um automático ao fechar cada dia.\nSQLite local com transações e verificação de integridade.\nLocal: " + ProjectSettings.globalize_path("user://careers.sqlite"), 15, MUTED)

func render_lines() -> void:
	label_at(side, "Editor de percurso", 25)
	label_at(side, "Clique nos pontos na ordem da ida. A ida aparece em azul e a volta em laranja; a volta usa os mesmos pontos em ordem inversa.", 15, MUTED)
	var name_input := LineEdit.new()
	name_input.text = draft_name
	name_input.max_length = 50
	name_input.text_changed.connect(func(value: String): draft_name = value)
	side.add_child(name_input)
	var count := SpinBox.new()
	count.min_value = 0
	count.max_value = 100
	count.value = draft_buses
	count.prefix = "Ônibus: "
	count.value_changed.connect(func(value: float): draft_buses = int(value))
	side.add_child(count)
	var names := PackedStringArray()
	for id in draft:
		names.append("%d · %s" % [int(id) + 1, str(sim.geo.stops[int(id)].name)])
	label_at(side, " → ".join(names) if not names.is_empty() else "Selecione dois ou mais pontos.", 14, GREEN)
	var route := sim.geo.circuit(draft)
	map.set_preview(route)
	if not route.is_empty():
		label_at(side, "IDA  %.2f km  azul\nVOLTA  %.2f km  laranja\nTOTAL  %.2f km" % [float(route.outbound_distance_km), float(route.return_distance_km), float(route.distance_km)], 17)
	button_at(side, "Salvar linha" if editing_id < 0 else "Aplicar edição", func():
		if sim.save_line(draft_name, draft, draft_buses, editing_id):
			status.text = "Linha salva. Avance o dia para operar."
			draft.clear()
			editing_id = -1
			render_side()
			refresh()
		else:
			status.text = sim.last_error)
	button_at(side, "Limpar / nova linha", func():
		draft.clear()
		editing_id = -1
		draft_name = "Nova linha"
		render_side()
		refresh())
	side.add_child(HSeparator.new())
	var forecast := sim.preview()
	for i in sim.state.lines.size():
		var line: Dictionary = sim.state.lines[i]
		var p: Dictionary = forecast.lines[i]
		label_at(side, "%03d / %s" % [int(line.id), str(line.name)], 18)
		label_at(side, "%d alocados • %d ativos • %d viagens/dia\n%.1f km/circuito • %s de receita" % [int(line.buses), int(p.active_buses), int(p.passengers), float(line.distance_km), money(int(p.revenue))], 14, MUTED)
		button_at(side, "Selecionar / editar", func(): line_editor(line))
		button_at(side, "Remover linha…", func():
			var dialog := ConfirmationDialog.new()
			dialog.title = "Remover linha"
			# Diferença de atendimento da rede, recalculada sem esta linha.
			var original: Array = sim.state.lines.duplicate(true)
			sim.state.lines.remove_at(i)
			var lost := maxi(0, int(forecast.passengers) - int(sim.preview().passengers))
			sim.state.lines = original
			dialog.dialog_text = "Remover %s?\nAté %d viagens diárias atualmente atendidas perderão serviço.\nA demanda pode ser redistribuída entre linhas restantes." % [str(line.name), lost]
			add_child(dialog)
			dialog.confirmed.connect(func():
				sim.remove_line(int(line.id))
				draft.clear()
				editing_id = -1
				render_side()
				refresh()
				dialog.queue_free())
			dialog.popup_centered())

func render_finances() -> void:
	var r := sim.preview()
	label_at(side, "Previsão do próximo dia", 25)
	for pair in [["Receita tarifária", r.revenue], ["Combustível", r.fuel], ["Manutenção básica", r.maintenance], ["Salários", r.salaries], ["Administração", r.administration], ["Resultado operacional", r.operating_result], ["Depreciação", r.depreciation], ["Lucro contábil", r.accounting_result], ["Fluxo de caixa", r.cash_flow]]:
		label_at(side, str(pair[0]) + "\n" + money(int(pair[1])), 16)
	label_at(side, "Compras e contratações são desembolsos no momento da decisão. Ônibus são ativos depreciados; compras não são custo operacional diário.", 14, MUTED)
	label_at(side, "HISTÓRICO / ÚLTIMOS 30 DIAS", 12, GREEN)
	var start := maxi(0, sim.state.history.size() - 30)
	for i in range(sim.state.history.size() - 1, start - 1, -1):
		var row: Dictionary = sim.state.history[i]
		label_at(side, "Dia %d • resultado %s\nReceita %s / custo %s" % [int(row.day), money(int(row.operating_result)), money(int(row.revenue)), money(int(row.cost))], 14, MUTED)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and store != null:
		store.close()
