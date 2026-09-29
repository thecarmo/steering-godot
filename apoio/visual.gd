extends Node2D

func atualizar(velocidade: Vector2, forca: Vector2) -> void:
	if velocidade.length_squared() > 1.0:
		$Corpo.rotation = velocidade.angle()
	$Velocidade.points = PackedVector2Array([Vector2.ZERO, velocidade * 0.35])
	$Forca.points = PackedVector2Array([Vector2.ZERO, forca * 0.35])
