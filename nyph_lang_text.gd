@tool
extends Control

@export var key: String:
	set(value):
		key = value
		# dirty.emit()
		on_dirty()
@export var pixel_size: int:
	set(value):
		pixel_size = value
		# dirty.emit()
		on_dirty()
@export var colour: Color:
	set(value):
		colour = value
		# dirty.emit()
		on_dirty()

var data = JSON.parse_string(FileAccess.get_file_as_string("res://nyphlang/data.json"))

class Glyph:
	var name = ""
	var code = 0 as int
	var top = 0 as int
	var bottom = 0 as int
	func _init(n, c, t, b) -> void:
		name = n
		code = c
		top = t
		bottom = b
	func _to_string() -> String:
		return "{" + name + ", " + str(code) + ", " + str(top) + ", " + str(bottom) + "}"
	## returns how much the upper glyph should be offset from the lower, or null if joiner should be used
	static func glyph_offset(lower: Glyph, upper: Glyph) -> Array:
		var t: int = lower.top
		var b: int = upper.bottom

		if t == b && b == 0b11111:
			return [true, 0]

		var tests = [-2, -1, 1, 2, 0]
		for x in tests:
			var a = b&t >> x if x>0 else b&t << abs(x)
			if a & a>>1 & a>>2 != 0:
				return [true, x]
		return [false, 0]

	func draw(dynim: Image, tlcorner: Array, colour: Color, pixel_size: int) -> void:
		for y in range(5):
			for x in range(5):
				var mask = 1 << (x + 5*y)
				#print(String.num_uint64(mask, 2))
				#print(String.num_uint64(code, 2))
				#print("-------------------------")
				if mask & code != 0:
					dynim.fill_rect(
						Rect2i((x+tlcorner[0])*pixel_size, (y+tlcorner[1])*pixel_size, pixel_size, pixel_size),
						colour
					)
				

class Compound:
	var glyphs: Array = []
	func _init(g: Array) -> void:
		glyphs = g
	func size(): return glyphs.size()
	func glyph(i): return glyphs[i] as Glyph
	func _to_string() -> String:
		return str(glyphs)

	func compound_offset():
		if glyphs.size() == 1: return {
			"left": 0,
			"right": 0,
			"merge":0,
			"join": 0
		}
		var mergers = 0
		var joiners = 0
		var centre = 0
		var centerrightmost = 0
		var centerleftmost = 0
		for i in range(1, glyphs.size()):
			var offset = Glyph.glyph_offset(glyphs[i-1], glyphs[i])
			if offset[0]: mergers += 1
			else: joiners += 1
			centre += 0 if not offset[0] else offset[1]
			if centre > centerrightmost: centerrightmost = centre
			if centre < centerleftmost: centerleftmost = centre
		return {
			"left": abs(centerleftmost),
			"right": centerrightmost,
			"merge":mergers,
			"join": joiners
		}
	func compound_size():
		var offset = compound_offset()
		return [
			offset.left + offset.right + 5,
			4*offset.merge + 8*offset.join + 5 # magic
		]

	func draw(dynim: Image, tlcorner: Array, colour: Color, pixel_size: int) -> void:
		var offset = compound_offset()
		var height = 4*offset.merge + 8*offset.join + 5
		var left = tlcorner[0] + offset.left
		var top = tlcorner[1] + height - 5
		glyphs[0].draw(dynim, [left, top], colour, pixel_size)

		for i in range(1, glyphs.size()):
			var goffset = Glyph.glyph_offset(glyphs[i-1], glyphs[i])
			left += goffset[1]
			if goffset[0]:
				top -= 4
				glyphs[i].draw(dynim, [left, top], colour, pixel_size)

enum Ending {
	STATEMENT,
	PAUSE,
	QUESTION,
	OPINION,
	METAPHOR,
	EXCLAMATION,
	COMMAND,
	SARCASM,
	UNUSED
}

class Strand:
	var compounds: Array = []
	var ending: Ending
	func _init(c, e: Ending) -> void:
		compounds = c
		ending = e
	func size(): return compounds.size()
	func compound(i): return compounds[i] as Compound
	func _to_string() -> String:
		return str(compounds)
	func strand_size():
		var height = 0
		var width = 0
		var csize
		@warning_ignore("shadowed_variable")
		for compound in compounds:
			csize = compound.compound_size()
			width += csize[0] + 1
			if csize[1] > height: height = csize[1]
		width -= 1
		var height_adjust = (8 if ending == Ending.EXCLAMATION else 4) if csize[1] == height else 0
		var width_adjust = 3 if ending == Ending.OPINION else (2 if ending in [Ending.STATEMENT, Ending.EXCLAMATION, Ending.PAUSE] else 4)
		return [
			width+width_adjust, height + height_adjust
		]
	func draw(dynim: Image, tlcorner: Array, colour: Color, pixel_size: int) -> void:
		var left = 0
		var final_height = 0
		var ssize = strand_size()
		@warning_ignore("shadowed_variable")
		for compound in compounds:
			var csize = compound.compound_size()
			compound.draw(dynim, [left+tlcorner[0], floor((ssize[1]-csize[1])/2)+tlcorner[1]], colour, pixel_size)
			left += csize[0] + 1
			final_height = csize[1]
		var top_of_ending = floor((ssize[1]-final_height)/2)+tlcorner[1]
		var rects: Array[Rect2i] = []
		if not ending == Ending.PAUSE:
			rects.append(Rect2i(left, top_of_ending, 1, final_height))
		var top_height = floor(final_height/2)
		match ending:
			Ending.STATEMENT: 
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1)
				]
			Ending.PAUSE:
				rects += [
					Rect2i(left, top_of_ending, 1, top_height),
					Rect2i(left, top_of_ending+top_height+1, 1, top_height),
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1)
				]
			Ending.QUESTION:
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left+2, top_height+1, 1, 1),
					Rect2i(left+2, top_height+3, 1, 1)
				]
			Ending.OPINION:
				rects += [
					Rect2i(left-1, top_of_ending-2, 3, 1),
					Rect2i(left-1, top_of_ending+final_height + 1, 3, 1)
				]
			Ending.METAPHOR:
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left+2, top_height-1, 1, 3),
					Rect2i(left+1, top_height, 1, 1)
				]
			Ending.EXCLAMATION:
				rects += [
					Rect2i(left, top_of_ending-4, 1, 1),
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left, top_of_ending+final_height+3, 1, 1)
				]
			Ending.COMMAND:
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left+1, top_height+1, 2, 1),
					Rect2i(left+1, top_height+3, 2, 1)
				]
			Ending.SARCASM:
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left+2, top_height+1, 1, 3)
				]
			Ending.UNUSED:
				rects += [
					Rect2i(left, top_of_ending-2, 1, 1),
					Rect2i(left, top_of_ending+final_height+1, 1, 1),
					Rect2i(left+2, top_height+1, 1, 3),
					Rect2i(left+1, top_height+1, 1, 1),
					Rect2i(left+1, top_height+3, 1, 1)
				]
		for rect in rects:
			dynim.fill_rect(Rect2i(rect.position*pixel_size, rect.size*pixel_size), colour)
		

func parse_ending(text:String):
	match text:
		"[statement]": return Ending.STATEMENT
		"[pause]": return Ending.PAUSE
		"[question]": return Ending.QUESTION
		"[opinion]": return Ending.OPINION
		"[metaphor]": return Ending.METAPHOR
		"[exclamation]": return Ending.EXCLAMATION
		"[command]": return Ending.COMMAND
		"[sarcasm]": return Ending.SARCASM
		"[unused]": return Ending.UNUSED
		_: return null

func parse(text: String) -> Strand:
	var glyphs = text.split(" ", false)
	var ending = parse_ending(glyphs[glyphs.size()-1])
	if ending != null:
		glyphs.remove_at(glyphs.size()-1)
	else:
		ending = Ending.STATEMENT
	var parts = Array(glyphs).map(
		func(compound): 
			var pain = Array(compound.split("/")).filter(
				func(glyph):
					return glyph in data["labels"]
			).map(
				func(glyph): 
					var code: int = data["labels"][glyph]
					return Glyph.new(
						glyph as String,
						code as int,
						data["glyphs"][str(code)]["top"] as int,
						data["glyphs"][str(code)]["bottom"] as int,
					)
			)
			pain.reverse() # why are you not in-place gah
			return Compound.new(pain)
	)
	return Strand.new(parts, ending)

func create_texture(text: String):
	var strand = parse(text)
	var whole_size = strand.strand_size()
	var dynim = Image.create_empty(whole_size[0]*pixel_size, whole_size[1]*pixel_size, false, Image.FORMAT_RGBA8)
	strand.draw(dynim, [0, 0], colour, pixel_size)

	print(Glyph.glyph_offset(strand.compound(0).glyph(0), strand.compound(0).glyph(1)))
	var top = strand.compound(0).glyph(0).top
	var bottom = strand.compound(0).glyph(1).bottom >>2
	print(String.num_int64((top & bottom) & (top & bottom)>>1 & (top & bottom)>>2, 2))

	return [ImageTexture.create_from_image(dynim), whole_size]


func _ready() -> void:
	var a = create_texture(key)
	var imtex = a[0]
	imtex.resource_name = key
	var texrect = TextureRect.new()
	texrect.texture = imtex
	add_child(texrect)
	size.x = a[1][0]*pixel_size
	size.y = a[1][1]*pixel_size
	


func on_dirty() -> void:
	var a = create_texture(key)
	var imtex = a[0]
	imtex.resource_name = key
	var texrect = get_children()[0]
	texrect.texture = imtex
	size.x = a[1][0]*pixel_size
	size.y = a[1][1]*pixel_size
