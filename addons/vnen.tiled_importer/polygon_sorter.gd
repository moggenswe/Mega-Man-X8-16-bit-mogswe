






















tool
extends Reference

var center



func sort_polygon(vertices):
	vertices = Array(vertices)

	var centroid = Vector2()
	var size = vertices.size()

	for i in range(0, size):
		centroid += vertices[i]

	centroid /= size

	center = centroid
	vertices.sort_custom(self, "is_less")

	return PoolVector2Array(vertices)


func is_less(a, b):
	if a.x - center.x >= 0 and b.x - center.x < 0:
		return false
	elif a.x - center.x < 0 and b.x - center.x >= 0:
		return true
	elif a.x - center.x == 0 and b.x - center.x == 0:
		if a.y - center.y >= 0 or b.y - center.y >= 0:
			return a.y < b.y
		return a.y > b.y

	var det = (a.x - center.x) * (b.y - center.y) - (b.x - center.x) * (a.y - center.y)
	if det > 0:
		return true
	elif det < 0:
		return false

	var d1 = (a - center).length_squared()
	var d2 = (b - center).length_squared()

	return d1 < d2
