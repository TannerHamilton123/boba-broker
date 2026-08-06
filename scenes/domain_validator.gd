
extends Node

var valid_domains = [
	"www.coolmathgames.com",
	"edit.coolmathgames.com",
	"stage.coolmathgames.com",
	"stage-edit.coolmathgames.com",
	"dev.coolmathgames.com",
	"m.coolmathgames.com",
	"www.coolmath-games.com",
	"edit.coolmath-games.com",
	"dev.coolmath-games.com",
	"m.coolmath-games.com"
]


func is_valid():
	if OS.is_debug_build():
		return true
	if not OS.get_name()=="HTML5":
		return true
	return valid_domains.has(get_domain())

func get_domain():
	return str(JavaScriptBridge.eval("document.location.host"))



