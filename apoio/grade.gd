extends Node

const TAMANHO = 100.0
var celulas: Dictionary = {}
var candidatos: int = 0

func celula(posicao: Vector2) -> Vector2i:
	return Vector2i(floori(posicao.x / TAMANHO), floori(posicao.y / TAMANHO))

func reconstruir(agentes: Array) -> void:
	celulas.clear()
	candidatos = 0
	for agente in agentes:
		var chave = celula(agente.global_position)
		if not celulas.has(chave):
			celulas[chave] = []
		celulas[chave].append(agente)

func consultar(agente) -> Array:
	var resultado: Array = []
	var centro = celula(agente.global_position)
	for x in range(-1, 2):
		for y in range(-1, 2):
			for outro in celulas.get(centro + Vector2i(x, y), []):
				if outro == agente:
					continue
				candidatos += 1
				if agente.global_position.distance_squared_to(outro.global_position) < TAMANHO * TAMANHO:
					resultado.append(outro)
	return resultado
