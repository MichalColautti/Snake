extends Node2D

@export var grid_size = 32

# Snake textures
@export var head_texture: Texture2D = preload("res://assets/SnakeHead.png")
@export var body_texture: Texture2D = preload("res://assets/SnakeBody.png")
@export var tail_texture: Texture2D = preload("res://assets/SnakeTail.png")

# Apple texture
@export var apple_texture: Texture2D = preload("res://assets/Apple.png")

var apple_position = Vector2.ZERO

@onready var tilemap = get_parent().get_node("GrassTileMapLayer") 

var direction = Vector2.RIGHT
var segments = [Vector2(5, 5), Vector2(4, 5), Vector2(3, 5)]  

var move_timer = 0.2
var time_passed = 0.0

# Swipe handling
var swipe_start_pos = Vector2.ZERO
var swipe_in_progress = false

func _ready():
	update_snake_visuals()
	randomize() 
	spawn_apple()

func _process(delta):
	time_passed += delta
	if time_passed >= move_timer:
		move()
		time_passed = 0.0

func move():
	var new_head = segments[0] + direction

	var cell = tilemap.get_cell_atlas_coords(new_head - Vector2(0, 1))
	if is_wall(cell):
		game_over()
		return

	segments.insert(0, new_head)
	if new_head == apple_position:
		spawn_apple()
	else:
		segments.pop_back()

	update_snake_visuals()
	update_apple_visual()

func is_wall(tile_id):
	return tile_id == Vector2i(2,0)

func game_over():
	print("Hit wall")
	get_tree().reload_current_scene()

func update_snake_visuals():
	for child in get_children():
		if child.name != "Apple":
			child.queue_free()

	for i in range(segments.size()):
		var segment_pos = segments[i]
		var sprite = Sprite2D.new()
		sprite.position = segment_pos * grid_size

		if i == 0:
			sprite.texture = head_texture
			sprite.rotation = direction.angle() + PI / 2
		elif i == segments.size() - 1:
			sprite.texture = tail_texture
			var tail_dir = (segments[i] - segments[i - 1]).normalized()
			sprite.rotation = tail_dir.angle() - PI / 2
		else:
			sprite.texture = body_texture 
		add_child(sprite)
	
func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_pos = event.position
			swipe_in_progress = true
		else:
			if swipe_in_progress:
				var swipe_end_pos = event.position
				handle_swipe(swipe_end_pos - swipe_start_pos)
				swipe_in_progress = false

	if event is InputEventScreenDrag:
		pass

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP: if direction != Vector2.DOWN: direction = Vector2.UP
			KEY_DOWN: if direction != Vector2.UP: direction = Vector2.DOWN
			KEY_LEFT: if direction != Vector2.RIGHT: direction = Vector2.LEFT
			KEY_RIGHT: if direction != Vector2.LEFT: direction = Vector2.RIGHT

func handle_swipe(delta):
	if delta.length() < 20:
		return

	if abs(delta.x) > abs(delta.y):
		# swipe poziomy
		if delta.x > 0 and direction != Vector2.LEFT:
			direction = Vector2.RIGHT
		elif delta.x < 0 and direction != Vector2.RIGHT:
			direction = Vector2.LEFT
	else:
		# swipe pionowy
		if delta.y > 0 and direction != Vector2.UP:
			direction = Vector2.DOWN
		elif delta.y < 0 and direction != Vector2.DOWN:
			direction = Vector2.UP

func spawn_apple():
	var map_rect = tilemap.get_used_rect()

	var min_x = map_rect.position.x + 3
	var max_x = map_rect.position.x + map_rect.size.x - 3
	var min_y = map_rect.position.y + 3
	var max_y = map_rect.position.y + map_rect.size.y - 3

	var found = false
	while not found:
		var pos = Vector2(randi() % (max_x - min_x + 1) + min_x, randi() % (max_y - min_y + 1) + min_y)
		if not segments.has(pos):
			apple_position = pos
			found = true
	
	update_apple_visual()

func update_apple_visual():
	if has_node("Apple"):
		get_node("Apple").queue_free()

	var apple_sprite = Sprite2D.new()
	apple_sprite.name = "Apple"
	apple_sprite.texture = apple_texture
	apple_sprite.position = apple_position * grid_size
	apple_sprite.z_index = 1
	add_child(apple_sprite)
	print("Nowe jabłko na: ", apple_position)
