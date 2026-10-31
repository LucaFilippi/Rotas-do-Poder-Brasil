# Fase 2 — gestão municipal avançada

Esta fase começou com duas correções solicitadas:

- Percursos separados em `outbound_path` e `return_path`. A ida é azul e a volta é laranja,
  inclusive no editor de linha; as distâncias aparecem separadamente.
- O mapa mantém as geometrias das ruas em cache e só as reconstrói quando há zoom, arraste
  ou redimensionamento. A animação só solicita novos frames quando há ônibus em operação.

## Gestão implementada

- Nove componentes por ônibus, desgaste por km e intervalo preventivo configurável.
- Inspeção AINDA RODA / NECESSITA CONSERTO, orçamento e prazo; falhas críticas bloqueiam serviço.
- Cobradores contratáveis reduzem embarque; cobrança pelo motorista aumenta tempo em 20%.
- Validadores exigem investimento, suporte e custo recorrente; automação afeta a equipe.
- Salários, jornada de 6 a 10h, adicional de horas extras e descanso diário implícito.
- Turnos manhã/entre picos/tarde/noturno, demanda por horário e fim de semana e congestionamento.
- Eventos determinísticos: greve condicionada à equipe insatisfeita, protestos por tarifa alta,
  interdição temporária e histórico de notícias. Negociação de bônus custa caixa.
- Satisfação por cobertura, acessibilidade e conforto; indicadores de equipe e reputação.
- Assessoria local baseada nos indicadores reais da partida.
- Garagens com seis vagas, expansão e custo operacional.
- Relatórios por categoria e histórico agrupado em períodos de 30 dias.
- SQLite versão 2 com migração das partidas versão 1, sem apagar os slots existentes.

## Limites explícitos

Modelo agregado: uma empresa escolhe um turno principal por dia, com um trabalhador por
ônibus/jornada e descanso mínimo de 14h. Não há editor de escalas individuais. Congestionamento
aplica multiplicadores por turno ao percurso real, sem simular fluxo individual por rua.
Greve: equipe <30 no sétimo dia; protesto: tarifa >R$10 no décimo dia; interdição: a cada 17 dias.
Garagens são capacidade administrativa, sem construção espacial. Reparos incluem peças no
orçamento agregado, sem estoque. Períodos financeiros são blocos de 30 dias, não meses civis.
Parâmetros são fictícios e não representam custos ou regras trabalhistas reais.

Investimentos e reparos aprovados reduzem caixa imediatamente e são registrados nas decisões.
Custos recorrentes entram no fechamento; aquisição de ônibus continua separada da operação.

Validação: 622 verificações headless e 3 testes Python; inclui 365 dias, oficina, cobradores,
bilhetagem, greve, protesto, garagens e migração. Interface renderizada em `tests/ui_smoke.gd`.
Fase 3 não iniciada.
