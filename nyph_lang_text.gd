extends Control

@export var key = ""

var data = JSON.parse_string(FileAccess.get_file_as_string("res://nyphlang/data.json"))

func parse(text: String):
	var glyphs = text.split(" ", false)
	var parts = Array(glyphs).map(
		func(compound): 
			var pain = Array(compound.split("/")).map(
				func(glyph): 
					var code: int = data["labels"][glyph]
					return {
						"name": glyph as String,
						"code": code as int,
						"top": data["glyphs"][str(code)]["top"] as int,
						"bottom": data["glyphs"][str(code)]["bottom"] as int,
					}
			)
			pain.reverse() # why are you not in-place gah
			return pain
	)
	return parts

## returns how much the upper glyph should be offset from the lower, or null if joiner should be used
func glyph_offset(lower, upper) -> Array:
	var top: int = lower.top
	var bottom: int = upper.bottom
	var tests = [0, -2, -1, 1, 2]
	for x in tests:
		var a = bottom & top>>x if x>0 else bottom & top<<abs(x)
		if a & a>>1 & a>>2 != 0:
			return [true, x]
	return [false, 0]

# func _compare_widths(w:int, dw:int) -> int:
# 	if (w)

# func glyph_size(glyph: Array):
# 	return [
# 		abs(glyph.reduce(
# 			func(accum, current): 
# 				return [
# 					current,
# 					accum[1]+glyph_offset(accum[0], current)[1]
# 				],
# 			[glyph[0], 0]
# 		)[1])+5,
# 		4*glyph.size()+1
# 	]

func glyph_size(glyphs: Array):
	if glyphs.size() == 1: return [5, 5]
	var mergers = 0
	var joiners = 0
	var centre = 0
	var centerrightmost = 0
	var centerleftmost = 0
	for i in range(1, len(glyphs)):
		var offset = glyph_offset(glyphs[i-1], glyphs[i])
		if offset[0]: mergers += 1
		else: joiners += 1
		centre += 0 if not offset[0] else offset[1]
		if centre > centerrightmost: centerrightmost = centre
		if centre < centerleftmost: centerleftmost = centre
	return [
		abs(centerleftmost) + centerrightmost + 5,
		4*mergers + 8*joiners + 5 # magic
	]

func text_size(glyphs: Array):
	var height = 0
	var width = 0
	for glyph in glyphs:
		var gsize = glyph_size(glyph)
		print(gsize)
		width += gsize[0] + 1
		if gsize[1] > height: height = gsize[1]
	width -= 1
	return [
		width, height
	]

func _ready() -> void:
	var parsed = parse(key)
	#print(parsed[0])
	#print(glyph_offset(parsed[0][0], parsed[0][1]))
	#print(parsed[0][0].top, " ", parsed[0][1].bottom)
	print(text_size(parsed))
	

	
