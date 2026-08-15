extends Node

const SAVE_PATH: String = "user://savegame.json"

func has_save(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)

func save_game(data: Dictionary, path: String = SAVE_PATH) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not open %s for writing (error %d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
	file.close()
	_sync_web_filesystem()

func load_game(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func clear_save(path: String = SAVE_PATH) -> void:
	# print("Clearing save at %s" % path)
	if FileAccess.file_exists(path):
		var dir := DirAccess.open(path.get_base_dir())
		if dir == null:
			push_warning("SaveManager: could not open %s for deletion (error %d)" % [path.get_base_dir(), DirAccess.get_open_error()])
			# print("SaveManager: could not open %s for deletion (error %d)" % [path.get_base_dir(), DirAccess.get_open_error()])
		else:
			var err := dir.remove(path.get_file())
			if err != OK:
				push_warning("SaveManager: failed to delete %s (error %d)" % [path, err])
	_sync_web_filesystem()

'''
On the Web export user:// lives in an in-memory FS that Godot mirrors to
IndexedDB. Writes only persist across a browser session if that mirror is
flushed, so force a sync right after any write/delete.
'''
func _sync_web_filesystem() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (typeof FS !== 'undefined') { FS.syncfs(false, function(err) {}); }")
