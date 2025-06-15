extends Node2D

@export var grid_size = 16

@export var head_texture: Texture2D = preload("res://assets/SnakeHead.png")
@export var body_texture: Texture2D = preload("res://assets/SnakeBody.png")
@export var tail_texture: Texture2D = preload("res://assets/SnakeTail.png")

@onready var tilemap = get_parent().get_node("GrassTileMapLayer") 

var direction = Vector2.RIGHT
var segments = [Vector2(5, 5), Vector2(4, 5), Vector2(3, 5)]  

var move_timer = 0.2
var time_passed = 0.0

func _ready():
	update_snake_visuals()

func _process(delta):
	time_passed += delta
	if time_passed >= move_timer:
		move()
		time_passed = 0.0

func move():
	var new_head = segments[0] + direction

	var cell = tilemap.get_cell_atlas_coords(new_head)
	if is_wall(cell):
		game_over()
		return
	else:
		segments.insert(0, new_head)
		segments.pop_back()
		update_snake_visuals()

func is_wall(tile_id):
	return tile_id == Vector2i(0,1)

func game_over():
	print("Hit wall")
	get_tree().reload_current_scene()

func update_snake_visuals():
	for child in get_children():
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
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP: if direction != Vector2.DOWN: direction = Vector2.UP
			KEY_DOWN: if direction != Vector2.UP: direction = Vector2.DOWN
			KEY_LEFT: if direction != Vector2.RIGHT: direction = Vector2.LEFT
			KEY_RIGHT: if direction != Vector2.LEFT: direction = Vector2.RIGHT
