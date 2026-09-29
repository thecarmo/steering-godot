# Steering Behaviour na Godot

Laboratório de 120 minutos, com 32 passos. Use **Godot 4.7.2 padrão**, com GDScript. O material foi validado nessa versão no macOS. Outras versões e sistemas não foram executados nesta entrega.

## Começo da atividade

Copie o repositório completo, incluindo `.git`, ou faça um clone. No terminal, dentro de `steering-godot`:

```sh
git switch starter
git switch -c minha-steering
```

Importe `project.godot` no gerenciador da Godot. F5 executa `cenas/laboratorio.tscn`. A starter inicia com o agente parado e as sete funções do exercício por completar. Siga `docs/ROTEIRO.md` e os slides, começando pelo passo 1. Se já existir uma branch chamada minha-steering, escolha outro nome.

A pasta entregue abre em `main`, que contém a solução completa para o professor. Este projeto é independente de FSM e BT. Mantém a separação usada nessas aulas, mas não depende de seus arquivos.

## O que você implementa

| Etapa | Função do aluno | Objetivo |
|---|---|---|
| A | `seek.gd`: `para` | Calcular a força para buscar um destino |
| B | `arrive.gd` e `pursuit.gd`: `calcular` | Chegar suavemente e antecipar um alvo móvel |
| C | `separacao.gd`, `alinhamento.gd`, `coesao.gd`, `flocking.gd`: `calcular` | Combinar regras locais em 48 agentes |

Todas ficam em `aluno/`. Preserve `extends Node`, as variáveis exportadas e `Seek.calcular`, que já chama `para`. As cenas e os nós das estratégias já estão montados. Os dois experimentos no Inspector devem terminar com os valores originais restaurados.

## Responsabilidades e padrões

- **Strategy:** nós com scripts diferentes oferecem a mesma operação `calcular(agente) -> Vector2`. A locomoção usa a estratégia selecionada sem conhecer sua fórmula.
- **Composição de componentes:** Flocking chama seus três filhos e soma seus vetores com pesos. Pursuit e Coesao reutilizam Seek como filho.
- **Spatial Partition:** `apoio/grade.gd` organiza agentes em um Dictionary de células. A consulta usa nove células e filtra o raio de 100 px.

`Node`, `CharacterBody2D`, `CollisionShape2D`, `StaticBody2D`, `Polygon2D`, `Line2D` e `Label` são nativos. As estratégias e a grade são scripts locais da aula. Não há addons, gerador de estados, árvore BT ou sistema genérico de registro de comportamentos.

| Pasta | Conteúdo |
|---|---|
| `aluno/` | As sete funções do exercício |
| `apoio/` | Integração, grade, controles, alvo, apresentação e cancelamento pronto |
| `cenas/` | Agente reutilizável e laboratório |
| `verificacao/` | Cenas de teste prontas para F6 e execução por terminal |
| `docs/` | Roteiro, entrega, relação com teoria e fontes |

## Controles

| Controle | Efeito |
|---|---|
| 1 | Seek em alvo parado |
| 2 | Arrive em alvo parado |
| 3 | Pursuit em alvo que se move horizontalmente |
| 4 | 48 boids com as três regras de flocking |
| 5 | Demonstração de cancelamento entre Seek e Flee |
| 6 | Arrive bloqueado por parede côncava |
| Clique esquerdo | Mover alvo nos modos 1, 2 e 5 |
| R | Reiniciar cenário atual |
| Espaço | Pausar ou retomar |

Azul mostra velocidade; laranja, força limitada. Essas linhas ficam ocultas no bando. A interface mostra rapidez, força e quantidade de agentes. O contador Candidatos mostra quantos outros agentes a grade examinou antes do filtro de distância. O total de comparação é 48 × 47 = 2.256, excluindo o próprio agente.

## Verificação durante a aula

Pare o jogo. Abra a cena correspondente em `verificacao/` e pressione **F6**:

| Cena | Resultado esperado após implementar a etapa |
|---|---|
| `etapa_a.tscn` | 22/22 |
| `etapa_b.tscn` | 33/33 |
| `etapa_c.tscn` | 46/46 |

A etapa C pode levar cerca de 70 segundos em velocidade normal. Procure `FALHA:` no painel Output se houver um erro. O teste C executado antes de concluir a atividade deve apontar funções ainda incompletas.

Alternativa de terminal, com `godot` disponível no PATH:

```sh
godot --headless --path . --editor --import
godot --headless --path . --fixed-fps 60 --script res://verificacao/executar.gd -- --etapa=3
```

Troque `3` por `1` ou `2` durante o exercício. No macOS, se `godot` não estiver no PATH, use `/Applications/Godot.app/Contents/MacOS/Godot` no lugar de `godot`. Sem `--etapa`, o script verifica o checkpoint indicado por `etapa.txt`; por isso, ao testar sua própria implementação, prefira sempre a opção explícita ou as cenas de F6.

## Checkpoints locais

| Referência | Conteúdo |
|---|---|
| branch `starter` | Base funcional e funções incompletas |
| tag `etapa-a-seek` | Seek completo |
| tag `etapa-b-arrive-pursuit` | Três comportamentos individuais completos |
| tag `etapa-c-flocking` | Solução completa |
| branch `main` | Mesma solução da etapa C |

Para retomar da etapa B preservando uma tentativa, pare o jogo e execute:

```sh
git stash push -u
git switch -c retomada-b etapa-b-arrive-pursuit
```

A tentativa anterior permanece no stash. Use outro nome se a branch existir. Não é necessário publicar no GitHub para realizar o exercício. Não há remoto configurado nesta entrega.

## Modelo e limites

A força é o erro entre velocidade desejada e atual, com massa 1 e ganho de resposta de 1 por segundo. O apoio limita a aceleração e a rapidez e integra com delta. `move_and_slide()` cuida do deslocamento e das colisões. Nenhuma estratégia altera diretamente a posição ou chama o movimento.

Arrive usa raio de 260 px. Pursuit limita a previsão a 1,5 s. O alinhamento acompanha a velocidade média, incluindo sua magnitude. As forças de todos os agentes são calculadas antes de mover qualquer corpo, evitando que a ordem das instâncias altere a percepção daquele passo.

A separação usa raio de 36 px, menor que a vizinhança de 100 px. Ela não garante ausência de sobreposição. No bando, os agentes não colidem entre si e reaparecem na borda oposta. A grade usa distância euclidiana, sem vizinhos através da borda. Posições coincidentes não geram divisão por zero.

O cenário 6 demonstra a limitação do Arrive diante de uma parede; este exercício não implementa desvio de obstáculos ou planejamento de rotas. A soma ponderada pode cancelar forças. A grade reduz candidatos na distribuição demonstrada, mas seu pior caso ainda é quadrático em regiões muito densas. O laboratório não é um benchmark de grande escala.
