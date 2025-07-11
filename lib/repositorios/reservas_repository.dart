

class ReservasRepository {
  static final ReservasRepository _instance = ReservasRepository._internal();
  factory ReservasRepository() => _instance;
  ReservasRepository._internal();

  final List<Map<String, dynamic>> reservas = [];

  void adicionarReserva(Map<String, dynamic> reserva) {
    reservas.add(reserva);
  }

  List<Map<String, dynamic>> getReservas() => reservas;

  List<Map<String, dynamic>> getProximasReservas() {
    return reservas.where((r) => r['status'] != 'Cancelada').toList();
  }
}
