class_name MunicipalManagement
extends RefCounted

const COMPONENTS = ["motor", "transmissão", "freios", "pneus", "suspensão", "elétrica", "portas", "ar-condicionado", "bilhetagem"]

static func initialize(state: Dictionary) -> void:
	if not state.has("management"):
		state.management = {"collectors": 0, "driver_salary": 18000, "collector_salary": 12000,
			"ticketing": false, "support": 0, "garages": 1, "garage_capacity": 6,
			"shift_hours": 8, "shift": 1, "preventive_km": 5000,
			"worker_satisfaction": 70.0, "reputation": 50.0, "events": []}
	for bus in state.buses:
		if not bus.has("components"):
			bus.components = {}
			for component in COMPONENTS:
				bus.components[component] = 100.0
			bus.workshop_days = 0
			bus.since_service_km = 0.0

static func available(bus: Dictionary) -> bool:
	if int(bus.workshop_days) > 0:
		return false
	for component in ["freios", "pneus", "portas"]:
		if float(bus.components[component]) < 35:
			return false
	return float(bus.components.motor) >= 20.0

static func inspection(bus: Dictionary) -> Dictionary:
	var defects := PackedStringArray()
	var wear := 0.0
	for component in COMPONENTS:
		var condition := float(bus.components[component])
		wear += 100.0 - condition
		if condition < 80:
			defects.append("%s: %.0f%%" % [component, condition])
	return {"critical": not available(bus) and int(bus.workshop_days) == 0,
		"defects": defects, "cost": int(round(wear * 1400)), "days": 2 if wear > 150 else 1}

static func context(state: Dictionary) -> Dictionary:
	var m: Dictionary = state.management
	var day := int(state.day) + 1
	var weekend := (day + 3) % 7 >= 5
	var strike: bool = float(m.worker_satisfaction) < 30 and day % 7 == 0
	var protest: bool = int(state.fare) > 1000 and day % 10 == 0
	var incident := day % 17 == 0
	var traffic: float = 1.0 if weekend else [1.55, 1.12, 1.65, 1.0][int(m.shift)]
	if incident:
		traffic *= 1.25
	var share: float = [0.34, 0.30, 0.29, 0.07][int(m.shift)]
	return {"strike": strike, "protest": protest, "incident": incident, "traffic": traffic,
		"demand_factor": share * 3.0 * (0.72 if weekend else 1.0) * (0.75 if protest else 1.0),
		"weekend": weekend}

static func close_day(state: Dictionary, report: Dictionary) -> void:
	var m: Dictionary = state.management
	for bus in state.buses:
		if int(bus.workshop_days) > 0:
			bus.workshop_days -= 1
			if int(bus.workshop_days) == 0:
				for component in COMPONENTS:
					bus.components[component] = 100.0
				bus.since_service_km = 0.0
	var operated := 0
	for entry in report.lines:
		for bus_id in entry.bus_ids:
			var bus: Dictionary = state.buses[int(bus_id)]
			var km := float(entry.km) / maxf(1, entry.active_buses)
			bus.since_service_km += km
			var overdue := 1.8 if float(bus.since_service_km) > int(m.preventive_km) else 1.0
			for component in COMPONENTS:
				bus.components[component] = maxf(0, float(bus.components[component]) - km * 0.002 * overdue)
			operated += 1
	var salary_factor := float(m.driver_salary) / 18000.0
	if int(m.collectors) > 0:
		salary_factor = minf(salary_factor, float(m.collector_salary) / 12000.0)
	var target := clampf(60 * salary_factor - maxf(0, float(m.shift_hours) - 8) * 8, 0, 100)
	m.worker_satisfaction = snappedf(float(m.worker_satisfaction) * 0.9 + target * 0.1, 0.01)
	m.reputation = snappedf(float(m.reputation) * 0.95 + float(state.satisfaction) * 0.05, 0.01)
	var ctx: Dictionary = report.context
	if ctx.strike:
		m.events.append({"day": state.day, "text": "Greve: insatisfação com salários e jornada interrompe a operação."})
	if ctx.protest:
		m.events.append({"day": state.day, "text": "Protesto contra a tarifa: procura e circulação reduzidas."})
	if ctx.incident:
		m.events.append({"day": state.day, "text": "Interdição temporária: aumento de 25% no tempo de viagem neste dia."})

static func advice(state: Dictionary, report: Dictionary) -> PackedStringArray:
	var messages := PackedStringArray()
	if report.active_buses == 0:
		messages.append("Sem operação: confira frota disponível, motoristas, oficina e greve.")
	if report.unserved > report.passengers:
		messages.append("Demanda reprimida elevada: conecte mais pontos e aumente capacidade nas linhas ocupadas.")
	if report.operating_result < 0:
		messages.append("Resultado negativo: compare tarifas, ocupação e custo por km antes de expandir.")
	if state.management.worker_satisfaction < 40:
		messages.append("Equipe insatisfeita: revise salário e jornada para reduzir risco de greve.")
	for bus in state.buses:
		if not available(bus):
			messages.append("BUS %03d indisponível: consulte Manutenção." % int(bus.id))
	if messages.is_empty():
		messages.append("Operação estável. Compare os turnos e preserve reserva de caixa para manutenção.")
	return messages
