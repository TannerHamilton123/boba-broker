
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
		print("DomainValidator: OS.is_debug_build() is true, skipping domain check")
		return true
	if not OS.has_feature("web"):
		print("DomainValidator: OS.has_feature('web') is false, skipping domain check")
		return true
	var domain = get_domain()
	print("DomainValidator: checking domain =", domain)
	return valid_domains.has(domain)

func get_domain():
	return str(JavaScriptBridge.eval("document.location.host"))



