import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'perfil.dart';
import 'relatarproblema.dart';
import 'detalhes.dart';
import 'login_registo.dart';
import 'home.dart';
import 'minhasreservas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacoesWidget extends StatefulWidget {
  final String nomeUtilizador;

  const NotificacoesWidget({super.key, required this.nomeUtilizador});

  static String routeName = 'notificacoes';
  static String routePath = '/notificacoes';

  @override
  State<NotificacoesWidget> createState() => _NotificacoesWidgetState();
}

class _NotificacoesWidgetState extends State<NotificacoesWidget> {
  List<Map<String, dynamic>> notificacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarNotificacoesFirestore();
  }

  Future<void> _carregarNotificacoesFirestore() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('notificacoes')
        .where('utilizador', isEqualTo: widget.nomeUtilizador)
        .orderBy('hora', descending: true)
        .get();

    final lista = snapshot.docs.map((doc) {
      final data = doc.data();
      final tipo = data['tipo'] ?? 'geral';

      // Ícones e cores diferentes consoante o tipo
      IconData icone;
      if (tipo == 'reserva') {
        icone = Icons.event_available;
      } else if (tipo == 'problema') {
        icone = Icons.report_problem;
        } else if (tipo == 'cancelamento') {
        icone = Icons.cancel; // Ícone para cancelamento
      } else {
        icone = Icons.notifications;
      }

      return {
        'titulo': data['titulo'] ?? 'Sem título',
        'mensagem': data['mensagem'] ?? 'Sem mensagem',
        'hora': _formatarHora(data['hora']),
        'icone': icone,
      };
    }).toList();

    if (mounted) {
      setState(() {
        notificacoes = lista;
      });
    }
  } catch (e) {
    debugPrint('Erro ao carregar notificações: $e');
  }
}



String _formatarHora(dynamic timestamp) {
  if (timestamp is Timestamp) {
    final dateTime = timestamp.toDate();
    final agora = DateTime.now();
    final diferenca = agora.difference(dateTime);

    if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minutos';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours} horas';
    } else if (diferenca.inDays == 1) {
      return 'ontem';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  return 'sem data';
}


  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

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
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomeWidget(nomeUtilizador: widget.nomeUtilizador),
            ));
          }),
          _drawerItem(Icons.person, 'Perfil', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => PerfilWidget(nomeUtilizador: widget.nomeUtilizador),
            ));
          }),
          _drawerItem(Icons.report_problem, 'Relatar Problema', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => RelatarProblemaWidget(nomeUtilizador: widget.nomeUtilizador),
            ));
          }),
          _drawerItem(Icons.bookmark, 'Minhas Reservas', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => MinhasReservasPage(nomeUtilizador: widget.nomeUtilizador),
            ));
          }),
          _drawerItem(Icons.info, 'Detalhes', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => DetalhesdaSalaEquipamentoWidget(nomeUtilizador: widget.nomeUtilizador),
            ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificações',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      drawer: _buildDrawer(),
      body: notificacoes.isEmpty
          ? Center(
              child: Text(
                'Sem notificações',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notificacoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notificacao = notificacoes[index];
                final icone = notificacao['icone'] as IconData? ?? Icons.notifications;
                final titulo = notificacao['titulo'] as String? ?? 'Sem título';
                final mensagem = notificacao['mensagem'] as String? ?? 'Sem mensagem';
                final hora = notificacao['hora'] as String? ?? '';

                return _buildNotificacaoItem(
                  icone: icone,
                  titulo: titulo,
                  mensagem: mensagem,
                  hora: hora,
                );
              },
            ),
    );
  }

  Widget _buildNotificacaoItem({
    required IconData icone,
    required String titulo,
    required String mensagem,
    required String hora,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(mensagem, style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(hora, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
