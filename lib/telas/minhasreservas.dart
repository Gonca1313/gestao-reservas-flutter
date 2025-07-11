import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // <-- Para formatar datas
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'package:google_fonts/google_fonts.dart';
import 'notificacoes.dart';
import 'novareserva.dart';
import 'perfil.dart';
import 'relatarproblema.dart';
import 'detalhes.dart';
import 'login_registo.dart';
import 'home.dart';

class MinhasReservasPage extends StatefulWidget {
  final String nomeUtilizador;

  const MinhasReservasPage({super.key, required this.nomeUtilizador});

  @override
  State<MinhasReservasPage> createState() => _MinhasReservasPageState();
}

class _MinhasReservasPageState extends State<MinhasReservasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchReservas() async {
    final querySnapshot = await _firestore
        .collection('reservas')
        .where('utilizador', isEqualTo: widget.nomeUtilizador)
        .orderBy('data', descending: false)
        .get();

    // Mapear os documentos para lista de Map
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      // Garantir que a data é um DateTime, pois Firestore armazena Timestamp
      if (data['data'] is Timestamp) {
        data['data'] = (data['data'] as Timestamp).toDate();
      }
      data['id'] = doc.id; // adicionar id para futuras operações (editar/cancelar)
      return data;
    }).toList();
  }

Future<void> _limparReservasCanceladas() async {
  final confirmacao = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Limpar Reservas Canceladas'),
      content: const Text('Tens a certeza que queres remover todas as reservas canceladas?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Não'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sim, limpar'),
        ),
      ],
    ),
  );

  if (confirmacao == true) {
    final reservasCanceladas = await _firestore
        .collection('reservas')
        .where('utilizador', isEqualTo: widget.nomeUtilizador)
        .where('status', isEqualTo: 'Cancelada')
        .get();

    for (var doc in reservasCanceladas.docs) {
      await doc.reference.delete();
    }

    setState(() {}); // Atualiza a interface
  }
}


  Future<void> _cancelarReserva(String reservaId) async {
  final confirmacao = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancelar Reserva'),
      content: const Text('Tens a certeza que queres cancelar esta reserva?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Não'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sim, Cancelar'),
        ),
      ],
    ),
  );

  if (confirmacao == true) {
    final DocumentSnapshot reservaSnapshot =
        await _firestore.collection('reservas').doc(reservaId).get();
    final reserva = reservaSnapshot.data() as Map<String, dynamic>;

    await _firestore.collection('reservas').doc(reservaId).update({
      'status': 'Cancelada',
      'cor': Colors.red.value, // Guardar a cor como int no Firestore
    });

    // Formatar data
    final Timestamp? dataTimestamp = reserva['data'];
    final String dataFormatada = dataTimestamp != null
        ? '${dataTimestamp.toDate().day.toString().padLeft(2, '0')}/'
          '${dataTimestamp.toDate().month.toString().padLeft(2, '0')}/'
          '${dataTimestamp.toDate().year}'
        : 'data desconhecida';

    // Verificar hora
    final String hora = reserva['hora'] ?? 'hora desconhecida';

    // Adicionar notificação de cancelamento
    await _firestore.collection('notificacoes').add({
      'utilizador': reserva['utilizador'],
      'titulo': 'Reserva Cancelada',
      'mensagem': 'A reserva para ${reserva['titulo']} em $dataFormatada às $hora foi cancelada.',
      'tipo': 'cancelamento',
      'hora': Timestamp.now(),
    });

    setState(() {});
  }
}



  Future<void> _editarReserva(String reservaId, Map<String, dynamic> reservaAtual) async {
    final TextEditingController tituloController =
        TextEditingController(text: reservaAtual['titulo']);
    final TextEditingController obsController =
        TextEditingController(text: reservaAtual['observacoes'] ?? '');

    DateTime dataSelecionada = reservaAtual['data'] ?? DateTime.now();
    String horarioSelecionado = reservaAtual['horario'] ?? '12:00';

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Editar Reserva'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor preencha o título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: obsController,
                    decoration: const InputDecoration(labelText: 'Observações'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Campo de Data
                  InkWell(
                    onTap: () async {
                      final novaData = await showDatePicker(
                        context: context,
                        initialDate: dataSelecionada,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (novaData != null) {
                        dataSelecionada = novaData;
                        setState(() {}); // Forçar atualização da data mostrada no diálogo
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(dataSelecionada)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Campo de Hora
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(horarioSelecionado.split(':')[0]),
                          minute: int.parse(horarioSelecionado.split(':')[1]),
                        ),
                      );
                      if (time != null) {
                        horarioSelecionado =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        setState(() {});
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(horarioSelecionado),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, {
                    'titulo': tituloController.text.trim(),
                    'observacoes': obsController.text.trim(),
                    'data': dataSelecionada,
                    'horario': horarioSelecionado,
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (resultado != null) {
      await _firestore.collection('reservas').doc(reservaId).update({
        'titulo': resultado['titulo'],
        'observacoes': resultado['observacoes'],
        'data': resultado['data'],
        'horario': resultado['horario'],
      });

      setState(() {});
    }
  }

  Future<void> _irParaNovaReserva() async {
  final novaReserva = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(
      builder: (context) => NovaReservaPage(nomeUtilizador: widget.nomeUtilizador),
    ),
  );

  if (novaReserva != null) {
    // Apenas atualiza a UI; a reserva já foi gravada na NovaReservaPage
    setState(() {});
  }
}


  // Drawer personalizado
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              'ReservaFácil Menu',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _drawerItem(Icons.home, 'Início', () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.person, 'Perfil', () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PerfilWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.report_problem, 'Relatar Problema', () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RelatarProblemaWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.info, 'Detalhes', () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DetalhesdaSalaEquipamentoWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.notifications, 'Notificações', () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NotificacoesWidget(nomeUtilizador: widget.nomeUtilizador),
    ),
  );
}),

          const Divider(),
          _drawerItem(Icons.logout, 'Logout', () {
            Navigator.pop(context);
            _confirmarLogout();
          }),
        ],
      ),
    );
  }

  // Item de menu reutilizável
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Diálogo de confirmação de logout
  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tens a certeza que queres terminar sessão?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginRegistoWidget()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardReserva(BuildContext context, Map<String, dynamic> reserva) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String dataFormatada = reserva['data'] is DateTime
        ? formatter.format(reserva['data'])
        : reserva['data'].toString();

    final Color corStatus = reserva['cor'] is int
        ? Color(reserva['cor'])
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: corStatus,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva['titulo'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(reserva['local'] ?? '', style: const TextStyle(color: Colors.grey)),
                      if (reserva['observacoes'] != null &&
                          (reserva['observacoes'] as String).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Observações: ${reserva['observacoes']}',
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: corStatus,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    reserva['status'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(dataFormatada),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(reserva['horario'] ?? ''),
              ],
            ),

            const SizedBox(height: 16),

            if (reserva['qrData'] != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: qr_flutter.QrImageView(
                    data: reserva['qrData'],
                    size: 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _cancelarReserva(reserva['id']),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => _editarReserva(reserva['id'], reserva),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Editar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Minhas Reservas'),
  actions: [
    IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Limpar Canceladas',
      onPressed: _limparReservasCanceladas,
    ),
  ],
),

      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReservas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            final reservas = snapshot.data ?? [];

            if (reservas.isEmpty) {
              return const Center(child: Text('Não tens reservas feitas.'));
            }

            return ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                return _buildCardReserva(context, reservas[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _irParaNovaReserva,
        child: const Icon(Icons.add),
        tooltip: 'Nova Reserva',
      ),
    );
  }
}
