@tool
class_name BasicPaddle
extends CharacterBody2D

## Is this the left paddle? Or the right one?
@export var player: Global.Player = Global.Player.LEFT:
	set = _set_player

## This is how fast your paddle moves.
@export_range(0, 3000.0, 5.0) var speed: float = 1000.0

## Should the paddle be able to move left and right?
@export var tennis_movement: bool = false

## Use this to change the texture of the paddle.
@export var texture: Texture2D = _initial_texture:
	set = _set_texture

## Use this to tint the texture of the paddle a different color.
@export var tint: Color = Color.WHITE:
	set = _set_tint

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _initial_texture: Texture2D = %Sprite2D.texture


func _set_player(new_player: Global.Player) -> void:
	player = new_player

	if not is_node_ready():
		return

	_sprite.flip_h = player == Global.Player.RIGHT


func _set_texture(new_texture: Texture2D) -> void:
	texture = new_texture

	if not is_node_ready():
		return

	if texture != null:
		_sprite.texture = texture
	else:
		_sprite.texture = _initial_texture


func _set_tint(new_tint: Color) -> void:
	tint = new_tint

	if not is_node_ready():
		return

	_sprite.modulate = tint


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
	_set_player(player)
	_set_texture(texture)
	_set_tint(tint)


func _physics_process(_delta: float) -> void:
	var direction: Vector2
	if player == Global.Player.RIGHT:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	elif player == Global.Player.LEFT:
		direction = Input.get_vector(
			"player_2_left", "player_2_right", "player_2_up", "player_2_down"
		)
	else:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction += Input.get_vector(
			"player_2_left", "player_2_right", "player_2_up", "player_2_down"
		)
	if direction:
		if not tennis_movement:
			direction.x = 0
			# Ensure up and down movement isn't affected by left-right input
			# (see Input.get_vector length limiting)
			direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2(0, 0)

	move_and_slide()


func on_ball_hit() -> void:
	DampedOscillator.animate(%Sprite2D, "scale", 600.0, 20.0, -15.0, 0.75)
