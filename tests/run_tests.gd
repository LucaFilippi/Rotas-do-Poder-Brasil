extends SceneTree

var checks := 0
var failures := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FALHOU: " + message)

func _initialize() -> void:
	call_deferred("run")

func ready_sim(geo: Geography) -> Simulation:
	var sim := Simulation.new(geo)
	sim.buy_bus()
	sim.hire_driver()
	sim.save_line("Centro", [0, 1, 2], 1)
	return sim

func run() -> void:
	var geo := Geography.new()
	check(geo.graph.get_point_count() > 1000, "Grafo real carregado")
	var circuit := geo.circuit([0, 1, 2])
	check(not circuit.is_empty(), "Circuito de ida e volta")
	check(circuit.path.front() == circuit.path.back(), "Circuito retorna à origem")
	for i in range(circuit.path.size() - 1):
		check(geo.edges.has("%d:%d" % [int(circuit.path[i]), int(circuit.path[i + 1])]), "Rota usa apenas aresta dirigida existente")
	check(geo.circuit([0, 0]).is_empty(), "Rejeita pontos repetidos")
	check(geo.circuit([-1, 1]).is_empty(), "Rejeita ponto fora do grafo")
	check(geo.circuit([0.5, 1]).is_empty(), "Rejeita identificador fracionário")
	var tiny := Geography.new()
	tiny.graph.clear()
	tiny.graph.add_point(1, Vector2.ZERO)
	tiny.graph.add_point(2, Vector2(1, 0))
	tiny.graph.add_point(3, Vector2(2, 0))
	tiny.graph.connect_points(1, 2, false)
	tiny.stops = [{"node": 1}, {"node": 2}, {"node": 3}]
	check(tiny.graph.get_id_path(2, 1).is_empty(), "Não contraria sentido único")
	check(tiny.circuit([0, 2]).is_empty(), "Rejeita desconexão")
	var sim := Simulation.new(geo)
	var cash: int = sim.state.cash
	check(sim.buy_bus(), "Compra com saldo")
	check(sim.state.cash == cash - int(sim.balance.bus_price), "Compra reduz caixa uma única vez")
	check(sim.state.buses[0].book_value == int(sim.balance.bus_price), "Compra é ativo")
	check(sim.save_line("Teste", [0, 1], 1), "Criação de linha")
	var report := sim.preview()
	check(report.passengers == 0 and report.active_buses == 0 and report.revenue == 0, "Sem motorista não opera")
	check(report.cost == int(sim.balance.administration_daily), "Administração sem operação")
	check(sim.hire_driver(), "Contratação")
	report = sim.preview()
	check(report.active_buses == 1 and report.passengers > 0, "Opera com motorista")
	check(report.revenue == report.passengers * sim.state.fare, "Receita = embarques × tarifa")
	check(report.cost == report.fuel + report.maintenance + report.salaries + report.administration, "Custos conciliam")
	check(report.operating_result == report.revenue - report.cost, "Resultado operacional")
	check(report.accounting_result == report.operating_result - report.depreciation, "Lucro contábil separado")
	check(report.passengers <= report.demand and report.unserved + report.passengers == report.demand, "Conservação da demanda")
	check(report.satisfaction >= 0 and report.satisfaction <= 100, "Satisfação limitada")
	var start_cash: int = sim.state.cash
	var start_book: int = sim.state.buses[0].book_value
	sim.advance_day()
	check(sim.state.cash == start_cash + report.cash_flow, "Fluxo de caixa diário")
	check(sim.state.buses[0].book_value == start_book - report.depreciation, "Depreciação do ativo")
	check(sim.state.buses[0].km > 0, "Quilometragem operacional")
	check(not sim.save_line("Frota excedida", [1, 2], 1), "Sem dupla alocação de ônibus")
	check(sim.save_line("Editada", [0, 2], 1, int(sim.state.lines[0].id)), "Edição da linha")
	check(sim.state.lines.size() == 1, "Edição não duplica linha")
	var baseline := sim.preview()
	sim.set_fare(5000)
	var expensive := sim.preview()
	check(expensive.demand < baseline.demand, "Tarifa alta reduz demanda")
	check(expensive.satisfaction < baseline.satisfaction, "Tarifa alta afeta satisfação")
	sim.set_fare(0)
	var free := sim.preview()
	check(free.revenue == 0 and free.operating_result < 0, "Tarifa zero não cria dinheiro")
	check(free.demand > baseline.demand, "Tarifa baixa aumenta demanda")
	check(free.passengers <= free.lines[0].capacity, "Capacidade limita embarques")
	check(free.unserved > 0, "Demanda reprimida é contabilizada")
	check(not sim.set_fare(-1), "Rejeita tarifa negativa")
	check(not sim.set_fare(5001), "Rejeita tarifa fora do cenário")
	var competition := ready_sim(geo)
	competition.buy_bus()
	competition.hire_driver()
	competition.save_line("Concorrente", [0, 1, 2], 1)
	var c := competition.preview()
	var assigned := 0
	for line in c.lines:
		assigned += int(line.demand)
	var covered := 0
	for id in [0, 1, 2]:
		covered += int(geo.stops[id].daily_demand)
	check(assigned == covered, "Linhas concorrentes dividem sem duplicar demanda")
	competition.state.drivers = 1
	c = competition.preview()
	check(c.active_buses == 1 and c.lines[1].active_buses == 0, "Motorista não pode atuar em dois ônibus")
	competition.state.cash = -100
	check(not competition.buy_bus() and not competition.hire_driver(), "Caixa negativo impede investimentos")
	check(competition.advance_day().cash == competition.state.cash, "Caixa negativo mantém contabilidade")
	competition.remove_line(1)
	check(competition.state.lines.size() == 1, "Remoção de linha")
	var long_run := ready_sim(geo)
	var direct := ready_sim(geo)
	for day in 365:
		var r := long_run.advance_day()
		check(r.unserved >= 0 and r.passengers >= 0 and r.passengers <= r.demand, "Conservação em partida longa")
	# Mesmo passo diário, agrupado em blocos como nas velocidades aceleradas.
	for block in 73:
		for day in 5:
			direct.advance_day()
	check(long_run.state == direct.state, "365 dias determinísticos independentemente do agrupamento temporal")
	check(long_run.state.day == 365, "Calendário avança exatamente 365 dias")
	var fuel_test := ready_sim(geo)
	var old_cost: int = fuel_test.preview().cost
	fuel_test.balance.fuel_cents_per_km *= 2
	check(fuel_test.preview().cost > old_cost, "Combustível altera custo")
	var saver := SaveStore.new("user://regression.sqlite")
	check(saver.save_game(long_run, 1), "Salvar SQLite")
	var loaded := Simulation.new(geo)
	check(saver.load_game(loaded, 1), "Carregar SQLite")
	check(JSON.stringify(loaded.state) == JSON.stringify(long_run.state), "Round trip integral")
	check(JSON.stringify(loaded.advance_day()) == JSON.stringify(long_run.advance_day()), "Continuidade após carregamento (precisão serializada)")
	check(saver.save_game(sim, 2), "Segundo slot independente")
	check(saver.save_game(sim, 0), "Autosave independente")
	check(not saver.load_game(loaded, 3), "Slot vazio informa falha")
	var preserved := loaded.state.duplicate(true)
	saver.db.query("UPDATE saves SET version=999 WHERE slot=2;")
	check(not saver.load_game(loaded, 2) and loaded.state == preserved, "Versão futura não altera partida")
	saver.db.query("UPDATE saves SET payload='corrompido' WHERE slot=0;")
	check(not saver.load_game(loaded, 0) and loaded.state == preserved, "Corrupção não altera partida")
	# Transação não consolidada, representando interrupção de salvamento.
	saver.db.query("BEGIN IMMEDIATE;")
	saver.db.query("UPDATE saves SET payload='interrompido' WHERE slot=1;")
	saver.db.query("ROLLBACK;")
	check(saver.load_game(loaded, 1), "Interrupção preserva versão consolidada")
	var bad := sim.state.duplicate(true)
	bad.lines[0].path = [123]
	check(not sim.validate(bad), "Rejeita rota adulterada")
	bad = sim.state.duplicate(true)
	bad.buses[0].km = "inválido"
	check(not sim.validate(bad), "Rejeita dado de frota inválido")
	bad = sim.state.duplicate(true)
	bad.cash = 1.5
	check(not sim.validate(bad), "Valores em centavos são inteiros")
	saver.close()
	# Ciclo completo da interface, usando a mesma cena de produção.
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	ui.store.close()
	ui.store = SaveStore.new("user://ui-test.sqlite")
	ui.show_city_selection()
	ui.sim = ready_sim(geo)
	ui.show_dashboard()
	for name in ["Mapa", "Linhas", "Frota", "Equipe", "Tarifas", "Finanças", "Partidas"]:
		ui.tab = name
		ui.render_side()
	ui.daily_step()
	check(ui.sim.state.day == 1, "Interface fecha dia no motor real")
	await process_frame
	var old_zoom: float = ui.map.zoom
	var anchor := Vector2(150, 150)
	var world_before: Vector2 = (anchor - ui.map.offset) / old_zoom
	var wheel := InputEventMouseButton.new()
	wheel.position = anchor
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	ui.map._gui_input(wheel)
	check(ui.map.zoom > old_zoom, "Zoom amplia o mapa")
	check(world_before.is_equal_approx((anchor - ui.map.offset) / ui.map.zoom), "Zoom preserva ponto sob o cursor")
	var offset_before: Vector2 = ui.map.offset
	ui.map.dragging = true
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(30, 40)
	ui.map._gui_input(motion)
	check(ui.map.offset == offset_before + Vector2(30, 40), "Arraste desloca mapa")
	ui.queue_free()
	await process_frame
	print("RESULTADO: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
