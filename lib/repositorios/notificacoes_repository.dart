// lib/repositorios/notificacoes_repository.dart
import 'package:flutter/material.dart';

class NotificacoesRepository {
  final List<Map<String, dynamic>> _notificacoes = [
    {
      'icone': Icons.event_available,
      'titulo': 'Reserva Confirmada',
      'mensagem': 'A sua reserva da Sala A3 foi confirmada para amanhã às 14h.',
      'hora': 'há 2 horas'
    },
    {
      'icone': Icons.warning_amber_rounded,
      'titulo': 'Problema Reportado',
      'mensagem': 'O problema no projetor da Sala B1 foi registado.',
      'hora': 'ontem'
    },
    {
      'icone': Icons.info_outline,
      'titulo': 'Nova Política de Uso',
      'mensagem': 'As regras de utilização das salas foram atualizadas.',
      'hora': 'há 3 dias'
    },
    // Mais notificações podem ser adicionadas dinamicamente
  ];

  List<Map<String, dynamic>> getNotificacoesRecentes({int limite = 3}) {
    return _notificacoes.take(limite).toList();
  }

  List<Map<String, dynamic>> getTodasNotificacoes() {
    return List.from(_notificacoes);
  }

  void adicionarNotificacao(Map<String, dynamic> notificacao) {
    _notificacoes.insert(0, notificacao);
  }

  void limparNotificacoes() {
    _notificacoes.clear();
  }
}
