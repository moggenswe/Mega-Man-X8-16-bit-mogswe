





















tool
extends Reference




func read_tmx(path):
	var parser = XMLParser.new()
	var err = parser.open(path)
	if err != OK:
		printerr("Error opening TMX file '%s'." % [path])
		return err

	while parser.get_node_type() != XMLParser.NODE_ELEMENT:
		err = parser.read()
		if err != OK:
			printerr("Error parsing TMX file '%s' (around line %d)." % [path, parser.get_current_line()])
			return err

	if parser.get_node_name().to_lower() != "map":
		printerr("Error parsing TMX file '%s'. Expected 'map' element.")
		return ERR_INVALID_DATA

	var data = attributes_to_dict(parser)
	if not "infinite" in data:
		data.infinite = false
	data.type = "map"
	data.tilesets = []
	data.layers = []

	err = parser.read()
	if err != OK:
		printerr("Error parsing TMX file '%s' (around line %d)." % [path, parser.get_current_line()])
		return err

	while err == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "map":
				break
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "tileset":
				
				if not parser.is_empty():
					var tileset = parse_tileset(parser)
					if typeof(tileset) != TYPE_DICTIONARY:
						
						return err
					data.tilesets.push_back(tileset)
				else:
					var tileset_data = attributes_to_dict(parser)
					if not "source" in tileset_data:
						printerr("Error parsing TMX file '%s'. Missing tileset source (around line %d)." % [path, parser.get_current_line()])
						return ERR_INVALID_DATA
					data.tilesets.push_back(tileset_data)

			elif parser.get_node_name() == "layer":
				var layer = parse_tile_layer(parser, data.infinite)
				if typeof(layer) != TYPE_DICTIONARY:
					printerr("Error parsing TMX file '%s'. Invalid tile layer data (around line %d)." % [path, parser.get_current_line()])
					return ERR_INVALID_DATA
				data.layers.push_back(layer)

			elif parser.get_node_name() == "imagelayer":
				var layer = parse_image_layer(parser)
				if typeof(layer) != TYPE_DICTIONARY:
					printerr("Error parsing TMX file '%s'. Invalid image layer data (around line %d)." % [path, parser.get_current_line()])
					return ERR_INVALID_DATA
				data.layers.push_back(layer)

			elif parser.get_node_name() == "objectgroup":
				var layer = parse_object_layer(parser)
				if typeof(layer) != TYPE_DICTIONARY:
					printerr("Error parsing TMX file '%s'. Invalid object layer data (around line %d)." % [path, parser.get_current_line()])
					return ERR_INVALID_DATA
				data.layers.push_back(layer)

			elif parser.get_node_name() == "group":
				var layer = parse_group_layer(parser, data.infinite)
				if typeof(layer) != TYPE_DICTIONARY:
					printerr("Error parsing TMX file '%s'. Invalid group layer data (around line %d)." % [path, parser.get_current_line()])
					return ERR_INVALID_DATA
				data.layers.push_back(layer)

			elif parser.get_node_name() == "properties":
				var prop_data = parse_properties(parser)
				if typeof(prop_data) == TYPE_STRING:
					return prop_data

				data.properties = prop_data.properties
				data.propertytypes = prop_data.propertytypes

		err = parser.read()

	return data



func read_tsx(path):
	var parser = XMLParser.new()
	var err = parser.open(path)
	if err != OK:
		printerr("Error opening TSX file '%s'." % [path])
		return err

	while parser.get_node_type() != XMLParser.NODE_ELEMENT:
		err = parser.read()
		if err != OK:
			printerr("Error parsing TSX file '%s' (around line %d)." % [path, parser.get_current_line()])
			return err

	if parser.get_node_name().to_lower() != "tileset":
		printerr("Error parsing TMX file '%s'. Expected 'map' element.")
		return ERR_INVALID_DATA

	var tileset = parse_tileset(parser)

	return tileset



func parse_tileset(parser):
	var err = OK
	var data = attributes_to_dict(parser)
	data.tiles = {}

	err = parser.read()
	while err == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "tileset":
				break

		elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "tile":
				var attr = attributes_to_dict(parser)
				var tile_data = parse_tile_data(parser)
				if typeof(tile_data) != TYPE_DICTIONARY:
					
					return tile_data
				if "properties" in tile_data and "propertytypes" in tile_data:
					if not "tileproperties" in data:
						data.tileproperties = {}
						data.tilepropertytypes = {}
					data.tileproperties[str(attr.id)] = tile_data.properties
					data.tilepropertytypes[str(attr.id)] = tile_data.propertytypes
					tile_data.erase("tileproperties")
					tile_data.erase("tilepropertytypes")
				data.tiles[str(attr.id)] = tile_data

			elif parser.get_node_name() == "image":
				var attr = attributes_to_dict(parser)
				if not "source" in attr:
					printerr("Error loading image tag. No source attribute found (around line %d)." % [parser.get_current_line()])
					return ERR_INVALID_DATA
				data.image = attr.source
				if "width" in attr:
					data.imagewidth = attr.width
				if "height" in attr:
					data.imageheight = attr.height

			elif parser.get_node_name() == "properties":
				var prop_data = parse_properties(parser)
				if typeof(prop_data) != TYPE_DICTIONARY:
					
					return prop_data

				data.properties = prop_data.properties
				data.propertytypes = prop_data.propertytypes

		err = parser.read()

	return data




func parse_tile_data(parser):
	var err = OK
	var data = {}
	var obj_group = {}
	if parser.is_empty():
		return data

	err = parser.read()
	while err == OK:

		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "tile":
				return data
			elif parser.get_node_name() == "objectgroup":
				data.objectgroup = obj_group

		elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "image":
				
				var attr = attributes_to_dict(parser)
				if not "source" in attr:
					printerr("Error loading image tag. No source attribute found (around line %d)." % [parser.get_current_line()])
					return ERR_INVALID_DATA
				data.image = attr.source
				data.imagewidth = attr.width
				data.imageheight = attr.height

			elif parser.get_node_name() == "objectgroup":
				obj_group = attributes_to_dict(parser)
				for attr in ["width", "height", "offsetx", "offsety"]:
					if not attr in obj_group:
						data[attr] = 0
				if not "opacity" in data:
					data.opacity = 1
				if not "visible" in data:
					data.visible = true
				if parser.is_empty():
					data.objectgroup = obj_group

			elif parser.get_node_name() == "object":
				if not "objects" in obj_group:
					obj_group.objects = []
				var obj = parse_object(parser)
				if typeof(obj) != TYPE_DICTIONARY:
					
					return obj
				obj_group.objects.push_back(obj)

			elif parser.get_node_name() == "properties":
				var prop_data = parse_properties(parser)
				data["properties"] = prop_data.properties
				data["propertytypes"] = prop_data.propertytypes
			
			elif parser.get_node_name() == "animation":
				var frame_list = []
				var err2 = parser.read()
				while err2 == OK:
					if parser.get_node_type() == XMLParser.NODE_ELEMENT:
						if parser.get_node_name() == "frame":
							var frame = {"tileid": 0, "duration": 0}
							for i in parser.get_attribute_count():
								if parser.get_attribute_name(i) == "tileid":
									frame["tileid"] = parser.get_attribute_value(i)
								if parser.get_attribute_name(i) == "duration":
									frame["duration"] = parser.get_attribute_value(i)
							frame_list.push_back(frame)
					elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
							if parser.get_node_name() == "animation":
								break
					err2 = parser.read()
				
				data["animation"] = frame_list

		err = parser.read()

	return data



static func parse_object(parser):
	var err = OK
	var data = attributes_to_dict(parser)

	if not parser.is_empty():
		err = parser.read()
		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "object":
					break

			elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "properties":
					var prop_data = parse_properties(parser)
					data["properties"] = prop_data.properties
					data["propertytypes"] = prop_data.propertytypes

				elif parser.get_node_name() == "point":
					data.point = true

				elif parser.get_node_name() == "ellipse":
					data.ellipse = true

				elif parser.get_node_name() == "polygon" or parser.get_node_name() == "polyline":
					var points = []
					var points_raw = parser.get_named_attribute_value("points").split(" ", false, 0)

					for pr in points_raw:
						points.push_back({
							"x": float(pr.split(",")[0]), 
							"y": float(pr.split(",")[1]), 
						})

					data[parser.get_node_name()] = points

			err = parser.read()

	return data




func parse_tile_layer(parser, infinite):
	var err = OK
	var data = attributes_to_dict(parser)
	data.type = "tilelayer"
	if not "x" in data:
		data.x = 0
	if not "y" in data:
		data.y = 0
	if infinite:
		data.chunks = []
	else:
		data.data = []

	var current_chunk = null
	var encoding = ""

	if not parser.is_empty():
		err = parser.read()

		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "layer":
					break
				elif parser.get_node_name() == "chunk":
					data.chunks.push_back(current_chunk)
					current_chunk = null

			elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "data":
					var attr = attributes_to_dict(parser)

					if "compression" in attr:
						data.compression = attr.compression

					if "encoding" in attr:
						encoding = attr.encoding
						if attr.encoding != "csv":
							data.encoding = attr.encoding

						if not infinite:
							err = parser.read()
							if err != OK:
								return err

							if attr.encoding != "csv":
								data.data = parser.get_node_data().strip_edges()
							else:
								var csv = parser.get_node_data().split(",", false)

								for v in csv:
									data.data.push_back(int(v.strip_edges()))

				elif parser.get_node_name() == "tile":
					var gid = int(parser.get_named_attribute_value_safe("gid"))
					if infinite:
						current_chunk.data.push_back(gid)
					else:
						data.data.push_back(gid)

				elif parser.get_node_name() == "chunk":
					current_chunk = attributes_to_dict(parser)
					current_chunk.data = []
					if encoding != "":
						err = parser.read()
						if err != OK:
							return err
						if encoding != "csv":
							current_chunk.data = parser.get_node_data().strip_edges()
						else:
							var csv = parser.get_node_data().split(",", false)
							for v in csv:
								current_chunk.data.push_back(int(v.strip_edges()))

				elif parser.get_node_name() == "properties":
					var prop_data = parse_properties(parser)
					if typeof(prop_data) == TYPE_STRING:
						return prop_data

					data.properties = prop_data.properties
					data.propertytypes = prop_data.propertytypes

			err = parser.read()

	return data



func parse_object_layer(parser):
	var err = OK
	var data = attributes_to_dict(parser)
	data.type = "objectgroup"
	data.objects = []

	if not parser.is_empty():
		err = parser.read()
		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "objectgroup":
					break
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "object":
					data.objects.push_back(parse_object(parser))
				elif parser.get_node_name() == "properties":
					var prop_data = parse_properties(parser)
					if typeof(prop_data) != TYPE_DICTIONARY:
						
						return prop_data
					data.properties = prop_data.properties
					data.propertytypes = prop_data.propertytypes

			err = parser.read()

	return data



func parse_image_layer(parser):
	var err = OK
	var data = attributes_to_dict(parser)
	data.type = "imagelayer"
	data.image = ""

	if not parser.is_empty():
		err = parser.read()

		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name().to_lower() == "imagelayer":
					break
			elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name().to_lower() == "image":
					var image = attributes_to_dict(parser)
					if not image.has("source"):
						printerr("Missing source attribute in imagelayer (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA
					data.image = image.source

				elif parser.get_node_name() == "properties":
					var prop_data = parse_properties(parser)
					if typeof(prop_data) != TYPE_DICTIONARY:
						
						return prop_data
					data.properties = prop_data.properties
					data.propertytypes = prop_data.propertytypes

			err = parser.read()

	return data



func parse_group_layer(parser, infinite):
	var err = OK
	var result = attributes_to_dict(parser)
	result.type = "group"
	result.layers = []

	if not parser.is_empty():
		err = parser.read()

		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name().to_lower() == "group":
					break
			elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "layer":
					var layer = parse_tile_layer(parser, infinite)
					if typeof(layer) != TYPE_DICTIONARY:
						printerr("Error parsing TMX file. Invalid tile layer data (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA
					result.layers.push_back(layer)

				elif parser.get_node_name() == "imagelayer":
					var layer = parse_image_layer(parser)
					if typeof(layer) != TYPE_DICTIONARY:
						printerr("Error parsing TMX file. Invalid image layer data (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA
					result.layers.push_back(layer)

				elif parser.get_node_name() == "objectgroup":
					var layer = parse_object_layer(parser)
					if typeof(layer) != TYPE_DICTIONARY:
						printerr("Error parsing TMX file. Invalid object layer data (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA
					result.layers.push_back(layer)

				elif parser.get_node_name() == "group":
					var layer = parse_group_layer(parser, infinite)
					if typeof(layer) != TYPE_DICTIONARY:
						printerr("Error parsing TMX file. Invalid group layer data (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA
					result.layers.push_back(layer)

				elif parser.get_node_name() == "properties":
					var prop_data = parse_properties(parser)
					if typeof(prop_data) == TYPE_STRING:
						return prop_data

					result.properties = prop_data.properties
					result.propertytypes = prop_data.propertytypes

			err = parser.read()
	return result



static func parse_properties(parser):
	var err = OK
	var data = {
		"properties": {}, 
		"propertytypes": {}, 
	}

	if not parser.is_empty():
		err = parser.read()

		while err == OK:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "properties":
					break
			elif parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "property":
					var prop_data = attributes_to_dict(parser)
					if not (prop_data.has("name") and prop_data.has("value")):
						printerr("Missing information in custom properties (around line %d)." % [parser.get_current_line()])
						return ERR_INVALID_DATA

					data.properties[prop_data.name] = prop_data.value
					if prop_data.has("type"):
						data.propertytypes[prop_data.name] = prop_data.type
					else:
						data.propertytypes[prop_data.name] = "string"

			err = parser.read()

	return data


static func attributes_to_dict(parser):
	var data = {}
	for i in range(parser.get_attribute_count()):
		var attr = parser.get_attribute_name(i)
		var val = parser.get_attribute_value(i)
		if val.is_valid_integer():
			val = int(val)
		elif val.is_valid_float():
			val = float(val)
		elif val == "true":
			val = true
		elif val == "false":
			val = false
		data[attr] = val
	return data
