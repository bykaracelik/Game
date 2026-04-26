extends Node2D

const ARENA_SIZE := Vector2(640.0, 360.0)
const PLAYER_SIZE := Vector2(28.0, 28.0)
const ENEMY_SIZE := Vector2(34.0, 34.0)
const PLAYER_SPEED := 220.0
const BASE_ENEMY_SPEED := 200.0

var player_pos := Vector2.ZERO
var enemy_pos := Vector2.ZERO
var enemy_velocity := Vector2.ZERO
var survival_time := 0.0
var best_time := 0.0
var game_over := false


func _ready() -> void:
	randomize()
	reset_game()


func reset_game() -> void:
	player_pos = Vector2(96.0, ARENA_SIZE.y * 0.5)
	enemy_pos = Vector2(ARENA_SIZE.x - 96.0, ARENA_SIZE.y * 0.5)
	enemy_velocity = Vector2.LEFT.rotated(randf_range(-0.9, 0.9)) * BASE_ENEMY_SPEED
	survival_time = 0.0
	game_over = false
	queue_redraw()


func _physics_process(delta: float) -> void:
	if game_over:
		return

	var input_dir := Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	)

	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()

	player_pos += input_dir * PLAYER_SPEED * delta
	player_pos.x = clamp(player_pos.x, PLAYER_SIZE.x * 0.5, ARENA_SIZE.x - PLAYER_SIZE.x * 0.5)
	player_pos.y = clamp(player_pos.y, PLAYER_SIZE.y * 0.5, ARENA_SIZE.y - PLAYER_SIZE.y * 0.5)

	var enemy_speed := BASE_ENEMY_SPEED + survival_time * 18.0
	enemy_velocity = enemy_velocity.normalized() * enemy_speed
	enemy_pos += enemy_velocity * delta

	if enemy_pos.x < ENEMY_SIZE.x * 0.5 or enemy_pos.x > ARENA_SIZE.x - ENEMY_SIZE.x * 0.5:
		enemy_velocity.x *= -1.0
		enemy_pos.x = clamp(enemy_pos.x, ENEMY_SIZE.x * 0.5, ARENA_SIZE.x - ENEMY_SIZE.x * 0.5)

	if enemy_pos.y < ENEMY_SIZE.y * 0.5 or enemy_pos.y > ARENA_SIZE.y - ENEMY_SIZE.y * 0.5:
		enemy_velocity.y *= -1.0
		enemy_pos.y = clamp(enemy_pos.y, ENEMY_SIZE.y * 0.5, ARENA_SIZE.y - ENEMY_SIZE.y * 0.5)

	survival_time += delta

	if Rect2(player_pos - PLAYER_SIZE * 0.5, PLAYER_SIZE).intersects(Rect2(enemy_pos - ENEMY_SIZE * 0.5, ENEMY_SIZE)):
		game_over = true
		best_time = max(best_time, survival_time)

	queue_redraw()


func _input(event: InputEvent) -> void:
	if not game_over:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		reset_game()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			reset_game()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("f5efe0"), true)
	draw_rect(Rect2(player_pos - PLAYER_SIZE * 0.5, PLAYER_SIZE), Color("2d9cdb"), true)
	draw_rect(Rect2(enemy_pos - ENEMY_SIZE * 0.5, ENEMY_SIZE), Color("eb5757"), true)

	var font := ThemeDB.fallback_font
	if font == null:
		return

	draw_string(font, Vector2(18.0, 30.0), "Sure: %.1f" % survival_time, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color("1f2937"))
	draw_string(font, Vector2(18.0, 58.0), "En iyi: %.1f" % max(best_time, survival_time), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color("4b5563"))
	draw_string(font, Vector2(18.0, 338.0), "WASD / Ok tuslari ile kac", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("374151"))

	if game_over:
		draw_rect(Rect2(Vector2(110.0, 110.0), Vector2(420.0, 120.0)), Color(0.12, 0.14, 0.18, 0.9), true)
		draw_string(font, Vector2(145.0, 160.0), "Carptin", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34, Color("ffffff"))
		draw_string(font, Vector2(145.0, 198.0), "Tekrar baslamak icin tikla veya Space'e bas", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("f9fafb"))
