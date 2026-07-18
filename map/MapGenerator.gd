class_name MapGenerator
extends RefCounted

var rng : RandomNumberGenerator;
var map: MapModel;
var min_area :int;
var area_number: int;

func generate(seed: int, min_area: int, area_number: int) -> MapModel:
	rng = RandomNumberGenerator.new();
	map = MapModel.new()
	self.min_area = min_area;
	self.area_number = area_number;
	
	generate_lines();

	var to_remove: Array[int] = compute_remove_indexes(seed)
	
	to_remove.sort()
	to_remove.reverse()
	
	for i in to_remove:
		map.lines.remove_at(i);
	return map


func generate_lines() -> void: 
	for y in range(0, area_number):
		var area_y := y * min_area

		for x in range(0, area_number):
			var area_x := x * min_area
			create_line(Vector2(area_x, area_y), Vector2(area_x, (y + 1) * min_area))
			create_line(Vector2(x * min_area, area_y), Vector2((x + 1) * min_area, area_y))

	for i in range(0, area_number):
		var max_area := min_area * area_number;
		create_line(Vector2(i * min_area, max_area), Vector2((i + 1) * min_area, max_area))
		create_line(Vector2(max_area,i * min_area), Vector2(max_area, (i + 1) * min_area))
		
func create_line(start: Vector2, end: Vector2) -> MapModel.Line:
	var line := MapModel.Line.new(start, end)
	map.lines.append(line)
	return line
	
func compute_remove_indexes(seed: int) -> Array[int]:
	var nb_lines := map.lines.size()
	var min_remove := int(nb_lines * 0.2)
	var max_remove := int(nb_lines * 0.7)
	
	var number_to_remove = rng.randi_range(min_remove, max_remove)
	var result:Array[int] = [];
	var attempt := 0;
	while result.size() < number_to_remove and attempt < 500:
		attempt += 1;
		var removed_index := rng.randi_range(0, nb_lines - 1);
		if removed_index in result:
			continue
		
		var line_to_test = map.lines[removed_index]
		var connections_at_start = count_connections(line_to_test.start, result)
		var connections_at_end = count_connections(line_to_test.end, result)
		if connections_at_start >= 3 and connections_at_end >= 3:
			result.append(removed_index)
			
		if not is_map_fully_connected(result):
				result.remove_at(result.size() - 1)
			
	return result;

func count_connections(point: Vector2, ignored_indexes: Array[int]) -> int:
	var count := 0
	for i in range(map.lines.size()):
		if i in ignored_indexes:
			continue
			
		var line = map.lines[i]
		if line.start.is_equal_approx(point) or line.end.is_equal_approx(point):
			count += 1

	return count
	
func is_map_fully_connected(ignored_indexes: Array[int]) -> bool:
	var active_lines: Array[MapModel.Line] = []
	
	for i in range(map.lines.size()):
		if not i in ignored_indexes:
			active_lines.append(map.lines[i])
			
	if active_lines.is_empty():
		return true
		
	var visited_lines := {}
	var queue := [active_lines[0]] 
	visited_lines[active_lines[0]] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		for other_line in active_lines:
			if other_line in visited_lines:
				continue
				
			if (current.start.is_equal_approx(other_line.start) or 
				current.start.is_equal_approx(other_line.end) or 
				current.end.is_equal_approx(other_line.start) or 
				current.end.is_equal_approx(other_line.end)):
				
				visited_lines[other_line] = true
				queue.append(other_line)
				
	return visited_lines.size() == active_lines.size()
