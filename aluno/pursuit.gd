extends Node

func calcular(agente) -> Vector2:
	var direcao = agente.alvo.global_position - agente.global_position
	var tempo = minf(direcao.length() / agente.velocidade_max, 1.5)
	var futuro = agente.alvo.global_position + agente.alvo.velocity * tempo
	return $Seek.para(agente, futuro)
