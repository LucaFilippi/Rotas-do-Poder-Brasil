# Validação do protótipo da Fase 1

Ambiente: Windows x86_64, Python 3.11, Godot 4.5.1, SQLite 4.6.

- Importação do projeto Godot: sem erros de script.
- 606 verificações headless: todas passaram.
- 3 testes Python de importação/proveniência: todos passaram.
- Partida determinística de 365 dias: resultados equivalentes ao agrupar passos diários.
- Salvamento/carregamento: conteúdo integral, continuidade, slots independentes, corrupção,
  versão incompatível e rollback de escrita interrompida.
- Economia: tarifa, receita, custos, combustível, depreciação, caixa negativo e capacidade.
- Operação: grafo dirigido, desconexão, ida/volta, edição, remoção, concorrência por demanda,
  disponibilidade de frota/motoristas, pan e zoom com preservação do ponto sob o cursor.
- Interface renderizada no Compatibility/OpenGL (Intel Iris Xe): menu, dashboard e editor
  de linhas inspecionados visualmente em 1280 × 800. Corrigida a largura do calendário
  para evitar que o cabeçalho ocupasse a tela.

Reproduzir: `python tools/check.py --godot <caminho-do-executavel-godot>`.
Capturas: `tests/ui_smoke.gd`; exemplo em `docs/images/prototipo.png`.
O workflow GitHub Actions executa a mesma suíte em Linux; seu resultado remoto deve ser
consultado no GitHub, não presumido a partir da execução local.

Limites: apenas recorte central de Campinas; pontos/demanda estimados; parâmetros fictícios;
restrições viárias conservadoras; frota de um modelo; jornada única simplificada.
O pacote executável de distribuição, mapas completos e sistemas avançados não fazem parte
desta entrega. A Fase 2 não foi iniciada.
