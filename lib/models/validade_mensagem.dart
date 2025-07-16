enum ValidadeMensagem {
  mensagemPadrao(Duration(days: 8)),
  evento(Duration(days: 10)),
  pedidoOracao(Duration(days: 5));

  final Duration duracao;
  const ValidadeMensagem(this.duracao);
}
