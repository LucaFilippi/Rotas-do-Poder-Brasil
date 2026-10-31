extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	ui.store.close()
	ui.store = SaveStore.new("res://.tools/ui-qa.sqlite")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	root.get_texture().get_image().save_png("res://build/qa/menu.png")
	ui.sim.buy_bus()
	ui.sim.hire_driver()
	ui.sim.save_line("01 · Conexão Centro", [0, 1, 2], 1)
	ui.show_dashboard()
	ui.daily_step()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/qa/dashboard.png")
	ui.tab = "Linhas"
	ui.render_side()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/qa/lines.png")
	ui.queue_free()
	await process_frame
	print("UI_SMOKE_OK")
	quit()
