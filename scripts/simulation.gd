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
	state = {"schema_version": 2, "city": "3509502", "company": company.strip_edges().left(60),
		"day": 0, "cash": int(balance.initial_cash), "fare": int(balance.reference_fare),
		"buses": [], "drivers": 0, "lines": [], "history": [], "decisions": [],
		"satisfaction": 50.0, "next_line_id": 1}
	MunicipalManagement.initialize(state)

func log_decision(text: String) -> void:
	state.decisions.append({"day": state.day, "text": text})

func buy_bus() -> bool:
	if state.buses.size() >= int(state.management.garages) * int(state.management.garage_capacity):
		last_error = "Garagens lotadas. Construa outra garagem."
		return false
	if state.cash < int(balance.bus_price):
		last_error = "Caixa insuficiente para comprar um ônibus."
		return false
	state.cash -= int(balance.bus_price)
	state.buses.append({"id": state.buses.size() + 1, "km": 0.0, "age_days": 0, "book_value": int(balance.bus_price)})
	MunicipalManagement.initialize(state)
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
		"buses": bus_count, "distance_km": route.distance_km, "path": route.path,
		"outbound_path": route.outbound_path, "return_path": route.return_path,
		"outbound_distance_km": route.outbound_distance_km, "return_distance_km": route.return_distance_km}
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
	MunicipalManagement.initialize(state)
	var management: Dictionary = state.management
	var context := MunicipalManagement.context(state)
	var available_ids: Array = []
	for i in state.buses.size():
		if MunicipalManagement.available(state.buses[i]):
			available_ids.append(i)
	var active := []
	var drivers_left := 0 if context.strike else int(state.drivers)
	var collectors_left := int(management.collectors)
	var coverage := {}
	for line in state.lines:
		var buses := mini(mini(int(line.buses), drivers_left), available_ids.size())
		drivers_left -= buses
		var bus_ids: Array = []
		for j in buses:
			bus_ids.append(available_ids.pop_front())
		var collectors := mini(buses, collectors_left)
		collectors_left -= collectors
		var km := float(line.distance_km)
		var boarding := 1.0 if management.ticketing or collectors == buses else 1.2
		var cycle_hours := km / float(balance.operational_speed_kmh) * float(context.traffic) * boarding + float(balance.terminal_minutes) / 60.0
		var cycles := int(floor(float(management.shift_hours) / maxf(cycle_hours, 0.01)))
		var entry := {"id": int(line.id), "name": line.name, "active_buses": buses,
			"bus_ids": bus_ids, "collectors": collectors, "cycle_hours": cycle_hours,
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
		var demand := int(round(float(stop.daily_demand) * factor * float(context.demand_factor)))
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
	var salaries := int(state.drivers) * int(management.driver_salary) + int(management.collectors) * int(management.collector_salary) + int(management.support) * 16000
	var ticketing_cost: int = state.buses.size() * 1500 if management.ticketing else 0
	var garage_cost := int(management.garages) * 10000
	var overtime := int(round(float(salaries) * maxf(0, float(management.shift_hours) - 8) / 8.0 * 1.5))
	var cost := fuel + maintenance + salaries + overtime + ticketing_cost + garage_cost + int(balance.administration_daily)
	var depreciation := 0
	for bus in state.buses:
		var age := int(bus.age_days)
		var before := maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * age / float(balance.bus_life_days))))
		var after := maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * (age + 1) / float(balance.bus_life_days))))
		depreciation += before - after
	var service_ratio := float(passengers) / maxf(1.0, total_demand)
	var affordability := clampf(1.0 - float(state.fare) / 2000.0, 0.0, 1.0)
	var comfort := 1.0
	if not state.buses.is_empty():
		comfort = 0.0
		for bus in state.buses:
			comfort += (float(bus.components["ar-condicionado"]) + float(bus.components["suspensão"])) / 200.0
		comfort /= state.buses.size()
	var target := clampf(service_ratio * 60.0 + affordability * 25.0 + comfort * 15.0, 0.0, 100.0)
	return {"day": int(state.day) + 1, "passengers": passengers, "demand": total_demand,
		"satisfaction_factors": {"coverage": service_ratio * 100, "affordability": affordability * 100, "comfort": comfort * 100},
		"context": context, "ticketing_cost": ticketing_cost, "garage_cost": garage_cost, "overtime": overtime,
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
	for line in report.lines:
		for bus_id in line.bus_ids:
			state.buses[int(bus_id)].km += float(line.km) / int(line.active_buses)
	for bus in state.buses:
		bus.age_days += 1
		bus.book_value = maxi(0, int(balance.bus_price) - int(floor(float(balance.bus_price) * int(bus.age_days) / float(balance.bus_life_days))))
	report.cash = state.cash
	state.history.append(report)
	MunicipalManagement.close_day(state, report)
	return report

func management_action(action: String, value: int = 0) -> bool:
	var m: Dictionary = state.management
	var cost := 0
	match action:
		"collector": cost = 80000
		"ticketing":
			if m.ticketing:
				return false
			cost = 1800000 + state.buses.size() * 450000
		"garage": cost = 12000000
		"negotiate": cost = (int(state.drivers) + int(m.collectors)) * 30000
		"repair":
			if value < 0 or value >= state.buses.size() or state.buses[value].workshop_days > 0:
				return false
			cost = MunicipalManagement.inspection(state.buses[value]).cost
		_:
			return false
	if state.cash < cost:
		last_error = "Caixa insuficiente."
		return false
	state.cash -= cost
	match action:
		"collector": m.collectors += 1
		"ticketing":
			m.ticketing = true
			m.support = 1
			m.worker_satisfaction = maxf(0, m.worker_satisfaction - 15)
		"garage": m.garages += 1
		"negotiate": m.worker_satisfaction = minf(100, m.worker_satisfaction + 20)
		"repair": state.buses[value].workshop_days = MunicipalManagement.inspection(state.buses[value]).days
	log_decision("%s: desembolso %d centavos" % [action, cost])
	return true

func validate(candidate: Variant) -> bool:
	# Validação sem mutação: nenhum dado carregado substitui estado antes de passar aqui.
	if not candidate is Dictionary:
		return false
	for key in ["schema_version", "city", "company", "day", "cash", "fare", "buses", "drivers", "lines", "history", "decisions", "satisfaction", "next_line_id"]:
		if not candidate.has(key):
			return false
	if candidate.schema_version != 2 or candidate.city != "3509502" or not candidate.company is String:
		return false
	if not candidate.get("management") is Dictionary:
		return false
	var limits := {"collectors": [0, 10000], "driver_salary": [9000, 50000], "collector_salary": [6000, 35000], "support": [0, 10000], "garages": [1, 10000], "garage_capacity": [6, 6], "shift_hours": [6, 10], "shift": [0, 3], "preventive_km": [1000, 10000], "worker_satisfaction": [0, 100], "reputation": [0, 100]}
	for key in limits:
		var value = candidate.management.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value < limits[key][0] or value > limits[key][1]:
			return false
	if not candidate.management.get("ticketing") is bool or not candidate.management.get("events") is Array:
		return false
	for key in ["day", "cash", "fare", "drivers", "satisfaction", "next_line_id"]:
		if not (candidate[key] is int or candidate[key] is float) or not is_finite(float(candidate[key])):
			return false
		if key != "satisfaction" and float(candidate[key]) != floor(float(candidate[key])):
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
		for key in ["id", "name", "stops", "buses", "distance_km", "path", "outbound_path", "return_path"]:
			if not line.has(key):
				return false
		if not line.name is String or not line.stops is Array or not line.buses is float and not line.buses is int:
			return false
		if not (line.id is int or line.id is float) or not is_finite(float(line.id)) or float(line.id) != floor(float(line.id)) or int(line.id) < 1 or ids.has(int(line.id)) or candidate.next_line_id <= line.id:
			return false
		ids[int(line.id)] = true
		if not is_finite(float(line.buses)) or float(line.buses) != floor(float(line.buses)) or line.buses < 0 or line.buses > 100:
			return false
		allocated += int(line.buses)
		var route := geo.circuit(line.stops)
		if route.is_empty() or not (line.distance_km is float or line.distance_km is int) or not is_equal_approx(float(route.distance_km), float(line.distance_km)):
			return false
		if not line.path is Array or route.path.size() != line.path.size():
			return false
		if not line.outbound_path is Array or not line.return_path is Array:
			return false
		if line.outbound_path != route.outbound_path or line.return_path != route.return_path:
			return false
		for j in route.path.size():
			if not (line.path[j] is int or line.path[j] is float) or float(line.path[j]) != float(route.path[j]):
				return false
	if allocated > candidate.buses.size():
		return false
	for bus in candidate.buses:
		if not bus is Dictionary:
			return false
		if not bus.get("components") is Dictionary:
			return false
		for component in MunicipalManagement.COMPONENTS:
			var condition = bus.components.get(component)
			if not (condition is int or condition is float) or not is_finite(float(condition)) or condition < 0 or condition > 100:
				return false
		for key in ["workshop_days", "since_service_km"]:
			var value = bus.get(key)
			if not (value is int or value is float) or not is_finite(float(value)) or value < 0:
				return false
		for key in ["id", "km", "age_days", "book_value"]:
			if not bus.has(key) or not (bus[key] is int or bus[key] is float) or not is_finite(float(bus[key])) or bus[key] < 0:
				return false
			if key != "km" and float(bus[key]) != floor(float(bus[key])):
				return false
	# Histórico é usado pela interface: valide também sua estrutura.
	for row in candidate.history:
		if not row is Dictionary:
			return false
		for key in ["day", "revenue", "cost", "operating_result", "cash_flow", "depreciation", "accounting_result", "passengers", "unserved", "cash"]:
			if not row.has(key) or not (row[key] is int or row[key] is float) or not is_finite(float(row[key])):
				return false
	return true
