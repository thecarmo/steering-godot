extends Node

func calcular(agente) -> Vector2:
	var direcao = Vector2.ZERO
	for vizinho in agente.vizinhos:
		var longe = agente.global_position - vizinho.global_position
		if longe.length_squared() > 0 and longe.length() < 36.0:
			direcao += longe / longe.length_squared()
	if direcao.is_zero_approx():
		return Vector2.ZERO
	return direcao.normalized() * agente.velocidade_max - agente.velocity
