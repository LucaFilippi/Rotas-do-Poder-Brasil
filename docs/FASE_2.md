# Fase 2 — gestão municipal avançada (início)

Esta fase começou com duas correções solicitadas:

- Percursos separados em `outbound_path` e `return_path`. A ida é azul e a volta é laranja,
  inclusive no editor de linha; as distâncias aparecem separadamente.
- O mapa mantém as geometrias das ruas em cache e só as reconstrói quando há zoom, arraste
  ou redimensionamento. A animação só solicita novos frames quando há ônibus em operação.

O segundo bloco da Fase 2 fica preparado para a próxima iteração: manutenção detalhada,
cobradores, bilhetagem, salários e escalas. Ele ainda não foi incluído nesta correção.

Compatibilidade: salvamentos novos incluem os dois caminhos; o esquema de salvamento continua
na versão 1 e rejeita dados sem os campos de rota para evitar carregar uma linha ambígua.
