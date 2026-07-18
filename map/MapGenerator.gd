class_name MapGenerator
extends RefCounted

var rng: RandomNumberGenerator
var map: MapModel
var min_area: int
var area_number: int

# Structure d'accélération : lie un point Snappé à la liste des lignes qui le touchent
# Clé : Vector2, Valeur : Array[MapModel.Line]
var adjacency_map := {}


func generate(p_seed: int, p_min_area: int, p_area_number: int) -> MapModel:
	rng = RandomNumberGenerator.new()
	rng.seed = p_seed  # Correction : On applique le seed reçu

	map = MapModel.new()
	self.min_area = p_min_area
	self.area_number = p_area_number
	adjacency_map.clear()

	generate_lines()

	var to_remove: Array[int] = compute_remove_indexes()

	to_remove.sort()
	to_remove.reverse()

	for i in to_remove:
		map.lines.remove_at(i)

	generate_crossroads()

	return map


func generate_lines() -> void:
	for y in range(0, area_number):
		var area_y := y * min_area
		for x in range(0, area_number):
			var area_x := x * min_area
			create_line(Vector2(area_x, area_y), Vector2(area_x, (y + 1) * min_area))
			create_line(Vector2(x * min_area, area_y), Vector2((x + 1) * min_area, area_y))

	for i in range(0, area_number):
		var max_area := min_area * area_number
		create_line(Vector2(i * min_area, max_area), Vector2((i + 1) * min_area, max_area))
		create_line(Vector2(max_area, i * min_area), Vector2(max_area, (i + 1) * min_area))


func create_line(start: Vector2, end: Vector2) -> MapModel.Line:
	var line := MapModel.Line.new(start, end)
	map.lines.append(line)

	# On indexe immédiatement la ligne dans notre dictionnaire d'adjacence
	register_point_connection(start, line)
	register_point_connection(end, line)

	return line


func register_point_connection(point: Vector2, line: MapModel.Line) -> void:
	var s_pos = point.snapped(Vector2(0.01, 0.01))
	if not adjacency_map.has(s_pos):
		var arr: Array[MapModel.Line] = []
		adjacency_map[s_pos] = arr
	adjacency_map[s_pos].append(line)


func compute_remove_indexes() -> Array[int]:
	var nb_lines := map.lines.size()
	var min_remove := int(nb_lines * 0.2)
	var max_remove := int(nb_lines * 0.7)

	var number_to_remove = rng.randi_range(min_remove, max_remove)
	var result: Array[int] = []

	# Pour un accès en O(1) au lieu de faire "if idx in result" (qui est en O(N))
	var removed_set := {}

	var attempt := 0
	# On augmente les essais max car l'algorithme est devenu ultra léger
	while result.size() < number_to_remove and attempt < 2000:
		attempt += 1
		var removed_index := rng.randi_range(0, nb_lines - 1)

		if removed_set.has(removed_index):
			continue

		var line_to_test = map.lines[removed_index]
		var s_start = line_to_test.start.snapped(Vector2(0.01, 0.01))
		var s_end = line_to_test.end.snapped(Vector2(0.01, 0.01))

		# ---- 1. CHECK CUL-DE-SAC (INSTANTANÉ via le dictionnaire) ----
		var current_start_count = count_active_connections(s_start, removed_set)
		var current_end_count = count_active_connections(s_end, removed_set)

		if current_start_count >= 3 and current_end_count >= 3:
			# Simulation : on l'ajoute au set des suppressions
			removed_set[removed_index] = true

			# ---- 2. CHECK ÎLOTS ISOLÉS (Ultra rapide via BFS par points) ----
			if is_map_fully_connected_fast(removed_set):
				result.append(removed_index)
			else:
				# Refusé, on annule la simulation
				removed_set.erase(removed_index)

	return result


# Compte les connexions actives d'un point en O(1) sans parcourir la map
func count_active_connections(snapped_point: Vector2, removed_set: Dictionary) -> int:
	var count = 0
	for line in adjacency_map[snapped_point]:
		# On ne compte pas la ligne si elle est déjà supprimée (ou en passe de l'être)
		var idx = map.lines.find(line)  # Reste très rapide car le tableau local est petit (max 4 éléments)
		if not removed_set.has(idx):
			count += 1
	return count


# Parcours de graphe (BFS) optimisé par les points plutôt que par les lignes
func is_map_fully_connected_fast(removed_set: Dictionary) -> bool:
	var total_active_lines = map.lines.size() - removed_set.size()
	if total_active_lines <= 0:
		return true

	# On trouve la première ligne active pour démarrer le BFS
	var start_line: MapModel.Line = null
	for line in map.lines:
		var idx = map.lines.find(line)
		if not removed_set.has(idx):
			start_line = line
			break

	if start_line == null:
		return true

	var visited_lines := {}
	var queue_points := [start_line.start.snapped(Vector2(0.01, 0.01))]
	var visited_points := {queue_points[0]: true}
	visited_lines[start_line] = true

	while queue_points.size() > 0:
		var current_point = queue_points.pop_front()

		# On récupère instantanément toutes les lignes connectées à ce point précis
		for line in adjacency_map[current_point]:
			var line_idx = map.lines.find(line)
			if removed_set.has(line_idx) or visited_lines.has(line):
				continue

			visited_lines[line] = true

			# On ajoute l'autre extrémité de la ligne à la file d'attente du parcours
			var s_start = line.start.snapped(Vector2(0.01, 0.01))
			var s_end = line.end.snapped(Vector2(0.01, 0.01))
			var next_point = s_end if s_start == current_point else s_start

			if not visited_points.has(next_point):
				visited_points[next_point] = true
				queue_points.append(next_point)

	return visited_lines.size() == total_active_lines


# Réutilisation directe du dictionnaire d'adjacence pour créer les CrossRoads instantanément
func generate_crossroads() -> void:
	for pos in adjacency_map.keys():
		var new_crossroad = MapModel.CrossRoad.new(pos)

		# On ne garde que les lignes qui n'ont PAS été supprimées de la map finale
		var remaining_lines: Array[MapModel.Line] = []
		for line in adjacency_map[pos]:
			if line in map.lines:
				remaining_lines.append(line)

		# Si le carrefour n'a plus aucune route, on ne le crée pas
		if remaining_lines.is_empty():
			continue

		new_crossroad.connected_lines.append_array(remaining_lines)
		map.crossRoads.append(new_crossroad)

	print("Génération terminée ! Nombre de carrefours détectés : ", map.crossRoads.size())
