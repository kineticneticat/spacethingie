extends Node

var langfile = "res://en_us.json"
var text = FileAccess.get_file_as_string(langfile)
var lang = JSON.parse_string(text)

func translate(key: String) -> String:
	return lang[key]
