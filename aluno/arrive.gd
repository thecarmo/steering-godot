extends Node

func calcular(agente) -> Vector2:
	var direcao = agente.alvo.global_position - agente.global_position
	var rapidez = agente.velocidade_max
	rapidez *= minf(direcao.length() / agente.raio_chegada, 1.0)
	var desejada = direcao.normalized() * rapidez
	return desejada - agente.velocity
