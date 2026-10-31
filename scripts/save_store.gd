class_name SaveStore
extends RefCounted

var db: SQLite
var last_error := ""

func _init(path: String = "user://careers.sqlite") -> void:
	db = SQLite.new()
	db.path = path
	if not db.open_db():
		last_error = "Não foi possível abrir o banco de partidas."
		return
	if not db.query("PRAGMA synchronous=FULL;") or not db.query("CREATE TABLE IF NOT EXISTS saves (slot INTEGER PRIMARY KEY, version INTEGER NOT NULL, payload TEXT NOT NULL, checksum TEXT NOT NULL, updated_at TEXT NOT NULL);"):
		last_error = db.error_message

func save_game(sim: Simulation, slot: int) -> bool:
	if slot < 0 or slot > 3 or not sim.validate(sim.state):
		last_error = "Partida inválida; salvamento preservado."
		return false
	var payload := JSON.stringify(sim.state)
	if not db.query("BEGIN IMMEDIATE;"):
		last_error = db.error_message
		return false
	var ok := db.query_with_bindings("INSERT OR REPLACE INTO saves(slot,version,payload,checksum,updated_at) VALUES(?,?,?,?,?);",
		[slot, 1, payload, payload.sha256_text(), Time.get_datetime_string_from_system()])
	if ok:
		ok = db.query("COMMIT;")
	if not ok:
		last_error = db.error_message
		db.query("ROLLBACK;")
	return ok

func load_game(sim: Simulation, slot: int) -> bool:
	if not db.query_with_bindings("SELECT version,payload,checksum FROM saves WHERE slot=?;", [slot]) or db.query_result.is_empty():
		last_error = "Este espaço não contém uma partida."
		return false
	var row: Dictionary = db.query_result[0]
	if int(row.version) != 1 or str(row.payload).sha256_text() != str(row.checksum):
		last_error = "Versão incompatível ou salvamento corrompido."
		return false
	var candidate = JSON.parse_string(row.payload)
	if not sim.validate(candidate):
		last_error = "Dados de partida inválidos. A partida atual foi preservada."
		return false
	sim.state = normalize_numbers(candidate)
	return true

func normalize_numbers(value: Variant) -> Variant:
	# JSON não distingue inteiros; restaura contadores e identificadores.
	if value is float and is_finite(value) and value == floor(value):
		return int(value)
	if value is Array:
		for i in value.size():
			value[i] = normalize_numbers(value[i])
	elif value is Dictionary:
		for key in value:
			value[key] = normalize_numbers(value[key])
	return value

func close() -> void:
	if db != null:
		db.close_db()
