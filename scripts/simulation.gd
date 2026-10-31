class_name Simulation
extends RefCounted

var geo: Geography
var balance: Dictionary
var state: Dictionary
var last_error := ""

func _init(geography: Geography = null) -> void:
	geo = geography if geography != null else Geography.new()
	balance = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	new_game("Empresa Municipal de Campinas")

func new_game(company: String) -> void:
	state = {"schema_version": 1, "city": "3509502", "company": company.strip_edges().left(60),
		"day": 0, "cash": int(balance.initial_cash), "fare": int(balance.reference_fare),
		"buses": [], "drivers": 0, "lines": [], "history": [], "decisions": [],
		"satisfaction": 50.0, "next_line_id": 1}

func log_decision(text: String) -> void:
	state.decisions.append({"day": state.day, "text": text})

func buy_bus() -> bool:
	if state.cash < int(balance.bus_price):
		last_error = "Caixa insuficiente para comprar um ônibus."
		return false
	state.cash -= int(balance.bus_price)
	state.buses.append({"id": state.buses.size() + 1, "km": 0.0, "age_days": 0, "book_value": int(balance.bus_price)})
	log_decision("Compra de ônibus: %d centavos" % int(balance.bus_price))
	return true

func hire_driver() -> bool:
	if state.cash < int(balance.hiring_cost):
		last_error = "Caixa insuficiente para contratação."
		return false
	state.cash -= int(balance.hiring_cost)
	state.drivers += 1
	log_decision("Contratação de motorista")
	return true

func set_fare(cents: int) -> bool:
	if cents < 0 or cents > 5000:
		return false
	state.fare = cents
	log_decision("Tarifa: %d centavos" % cents)
	return true

func save_line(name: String, stop_ids: Array, bus_count: int, line_id: int = -1) -> bool:
	var route := geo.circuit(stop_ids)
	if route.is_empty():
		last_error = "Selecione pelo menos dois pontos distintos com ida e volta conectadas."
		return false
	if bus_count < 0 or bus_count > 100:
		last_error = "Alocação inválida."
		return false
	var used := 0
	var index := -1
	for i in state.lines.size():
		if int(state.lines[i].id) == line_id:
			index = i
		else:
			used += int(state.lines[i].buses)
	if line_id != -1 and index == -1:
		last_error = "Linha inexistente."
		return false
	if used + bus_count > state.buses.size():
		last_error = "Compre mais ônibus ou reduza a alocação de outras linhas."
		return false
	var line := {"id": line_id, "name": name.strip_edges().left(50), "stops": stop_ids.duplicate(),
		"buses": bus_count, "distance_km": route.distance_km, "path": route.path}
	if line.name.is_empty():
		line.name = "Linha municipal"
	if index < 0:
		line.id = state.next_line_id
		state.next_line_id += 1
		state.lines.append(line)
	else:
		state.lines[index] = line
	log_decision("Percurso/alocação: " + line.name)
	return true

func remove_line(id: int) -> void:
	for i in state.lines.size():
		if int(state.lines[i].id) == id:
			log_decision("Remoção: " + str(state.lines[i].name))
			state.lines.remove_at(i)
			return

func preview() -> Dictionary:
	var active := []
	var drivers_left := int(state.drivers)
	var coverage := {}
	for line in state.lines:
		var buses := mini(int(line.buses), drivers_left)
		drivers_left -= buses
		var km := float(line.distance_km)
		var cycle_hours := km / float(balance.operational_speed_kmh) + float(balance.terminal_minutes) / 60.0
		var cycles := int(floor(float(balance.service_hours) / maxf(cycle_hours, 0.01)))
		var entry := {"id": int(line.id), "name": line.name, "active_buses": buses,
			"cycles": cycles, "capacity": buses * cycles * int(balance.bus_capacity),
			"km": buses * cycles * km, "passengers": 0, "demand": 0, "revenue": 0, "cost": 0}
		active.append(entry)
		if buses > 0 and cycles > 0:
			for stop in line.stops:
				var id := int(stop)
				if not coverage.has(id):
					coverage[id] = []
				coverage[id].append(active.size() - 1)
	var total_demand := 0
	var factor := exp(-float(balance.fare_elasticity) * (float(state.fare) / float(balance.reference_fare) - 1.0))
	for stop in geo.stops:
		var demand := int(round(float(stop.daily_demand) * factor))
		total_demand += demand
		var candidates: Array = coverage.get(int(stop.id), [])
		# Divisão inteira com resto atribuído uma única vez.
		for j in candidates.size():
			active[candidates[j]].demand += int(demand / candidates.size()) + (1 if j < demand % candidates.size() else 0)
	var passengers := 0
	var revenue := 0
	var fuel := 0
	var maintenance := 0
	var operated := 0
	var total_km := 0.0
	for i in active.size():
		var entry: Dictionary = active[i]
		var line: Dictionary = state.lines[i]
		# Viagens longas reduzem a atratividade, sem criar nova demanda.
		var time_factor := minf(1.0, 60.0 / maxf(60.0, float(line.distance_km) / float(balance.operational_speed_kmh) * 60.0))
		entry.passengers = mini(int(entry.capacity), int(float(entry.demand) * time_factor))
		entry.revenue = int(entry.passengers) * int(state.fare)
		var f := int(round(float(entry.km) * float(balance.fuel_cents_per_km)))
		var m := int(round(float(entry.km) * float(balance.maintenance_cents_per_km)))
		entry.cost = f + m + int(entry.active_buses) * int(balance.driver_daily_salary)
		passengers += int(entry.passengers)
		revenue += int(entry.revenue)
		fuel += f
		maintenance += m
		operated += int(entry.active_buses)
		total_km += float(entry.km)
	var salaries := int(state.drivers) * int(balance.driver_daily_salary)
	var cost := fuel + maintenance + salaries + int(balance.administration_daily)
	var depreciation := 0
	for bus in state.buses:
		var age := int(bus.age_days)
		var before := maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * age / float(balance.bus_life_days))))
		var after := maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * (age + 1) / float(balance.bus_life_days))))
		depreciation += before - after
	var service_ratio := float(passengers) / maxf(1.0, total_demand)
	var affordability := clampf(1.0 - float(state.fare) / 2000.0, 0.0, 1.0)
	var target := clampf(service_ratio * 70.0 + affordability * 30.0, 0.0, 100.0)
	return {"day": int(state.day) + 1, "passengers": passengers, "demand": total_demand,
		"unserved": total_demand - passengers, "revenue": revenue, "fuel": fuel, "maintenance": maintenance,
		"salaries": salaries, "administration": int(balance.administration_daily), "cost": cost,
		"operating_result": revenue - cost, "depreciation": depreciation,
		"accounting_result": revenue - cost - depreciation, "cash_flow": revenue - cost,
		"active_buses": operated, "km": total_km, "lines": active,
		"satisfaction": snappedf(float(state.satisfaction) * 0.8 + target * 0.2, 0.01)}

func advance_day() -> Dictionary:
	var report := preview()
	state.cash += int(report.cash_flow)
	state.day += 1
	state.satisfaction = report.satisfaction
	var bus_index := 0
	for line in report.lines:
		for j in int(line.active_buses):
			state.buses[bus_index].km += float(line.km) / int(line.active_buses)
			bus_index += 1
	for bus in state.buses:
		bus.age_days += 1
		bus.book_value = maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * int(bus.age_days) / float(balance.bus_life_days))))
	report.cash = state.cash
	state.history.append(report)
	return report

func validate(candidate: Variant) -> bool:
	# Validação sem mutação: nenhum dado carregado substitui estado antes de passar aqui.
	if not candidate is Dictionary:
		return false
	for key in ["schema_version", "city", "company", "day", "cash", "fare", "buses", "drivers", "lines", "history", "decisions", "satisfaction", "next_line_id"]:
		if not candidate.has(key):
			return false
	if candidate.schema_version != 1 or candidate.city != "3509502" or not candidate.company is String:
		return false
	for key in ["day", "cash", "fare", "drivers", "satisfaction", "next_line_id"]:
		if not (candidate[key] is int or candidate[key] is float) or not is_finite(float(candidate[key])):
			return false
	for key in ["buses", "lines", "history", "decisions"]:
		if not candidate[key] is Array:
			return false
	if candidate.day < 0 or candidate.drivers < 0 or candidate.fare < 0 or candidate.fare > 5000 or candidate.satisfaction < 0 or candidate.satisfaction > 100:
		return false
	var ids := {}
	var allocated := 0
	for line in candidate.lines:
		if not line is Dictionary:
			return false
		for key in ["id", "name", "stops", "buses", "distance_km", "path"]:
			if not line.has(key):
				return false
		if not line.name is String or not line.stops is Array or not line.buses is float and not line.buses is int:
			return false
		if not (line.id is int or line.id is float) or int(line.id) < 1 or ids.has(int(line.id)) or candidate.next_line_id <= line.id:
			return false
		ids[int(line.id)] = true
		if line.buses < 0 or line.buses > 100:
			return false
		allocated += int(line.buses)
		var route := geo.circuit(line.stops)
		if route.is_empty() or not (line.distance_km is float or line.distance_km is int) or not is_equal_approx(float(route.distance_km), float(line.distance_km)):
			return false
		if not line.path is Array or route.path != line.path:
			return false
	if allocated > candidate.buses.size():
		return false
	for bus in candidate.buses:
		if not bus is Dictionary:
			return false
		for key in ["id", "km", "age_days", "book_value"]:
			if not bus.has(key) or not (bus[key] is int or bus[key] is float) or not is_finite(float(bus[key])) or bus[key] < 0:
				return false
	# Histórico é usado pela interface: valide também sua estrutura.
	for row in candidate.history:
		if not row is Dictionary:
			return false
		for key in ["day", "revenue", "cost", "operating_result", "cash_flow", "depreciation", "accounting_result", "passengers", "unserved", "cash"]:
			if not row.has(key) or not (row[key] is int or row[key] is float) or not is_finite(float(row[key])):
				return false
	return true
