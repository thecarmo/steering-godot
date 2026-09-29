extends CharacterBody2D

@export var velocidade_max: float = 180.0
@export var forca_max: float = 280.0
@export var raio_chegada: float = 260.0
var alvo: CharacterBody2D
var vizinhos: Array = []
var estrategia: Node
var forca := Vector2.ZERO

func mover(delta: float) -> void:
	var aceleracao = forca.limit_length(forca_max)
	velocity = (velocity + aceleracao * delta).limit_length(velocidade_max)
	move_and_slide()
	if get_slide_collision_count() > 0:
		velocity = get_real_velocity()
	$Visual.atualizar(velocity, forca.limit_length(forca_max))
