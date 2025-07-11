import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_registo.dart'; // Para logout
import 'minhasreservas.dart';
import 'novareserva.dart';
import 'relatarproblema.dart'; // Importa a página que mostraste
import 'perfil.dart'; // Importa a página que mostraste
import 'notificacoes.dart'; // Importa a página que mostraste
import 'detalhes.dart'; // Importa a página que mostraste
import '../repositorios/reservas_repository.dart'; // Importa o repositório de reservas
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeWidget extends StatefulWidget {
  final String nomeUtilizador;

  const HomeWidget({super.key, required this.nomeUtilizador});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  

  @override
  Widget build(BuildContext context) {
    final proximasReservas = ReservasRepository().getProximasReservas();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],

        // ** Aqui está o AppBar com o botão para abrir o drawer **
        appBar: AppBar(
          title: const Text('ReservaFácil'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        drawer: _buildDrawer(), // menu lateral

        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //_buildHeader(), // Já tens AppBar, podes remover este header se quiser
                _buildWelcomeSection(),
                _buildActionsSection(),
                _buildNotificationsSection(),
                _buildUpcomingReservationsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'ReservaFácil Menu',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _drawerItem(Icons.person, 'Perfil', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  PerfilWidget(nomeUtilizador: widget.nomeUtilizador)));
        }),
        _drawerItem(Icons.report_problem, 'Relatar Problema', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  RelatarProblemaWidget(nomeUtilizador: widget.nomeUtilizador)));
        }),
        _drawerItem(Icons.info, 'Detalhes', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  DetalhesdaSalaEquipamentoWidget(nomeUtilizador: widget.nomeUtilizador)));
        }),
        _drawerItem(Icons.notifications, 'Notificações', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  NotificacoesWidget(nomeUtilizador: widget.nomeUtilizador)));
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

// Função auxiliar para mostrar o AlertDialog
void _confirmarLogout() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tens a certeza que queres terminar sessão?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
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


  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: GoogleFonts.inter(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeSection() {
  // Gerar iniciais do nome
  String getIniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    } else {
      return partes[0][0].toUpperCase() + partes[1][0].toUpperCase();
    }
  }

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Text(
            getIniciais(widget.nomeUtilizador),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${widget.nomeUtilizador}',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Bem-vindo de volta',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _actionButton(
            Icons.meeting_room,
            'Reservar Sala ou Equipamento',
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  NovaReservaPage(nomeUtilizador: widget.nomeUtilizador)),
              ).then((_) => setState(() {})); // Atualiza ao voltar
            },
          ),
          const SizedBox(width: 16),
          _actionButton(
            Icons.calendar_today,
            'Minhas Reservas',
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MinhasReservasPage(nomeUtilizador: widget.nomeUtilizador)),
              ).then((_) => setState(() {})); // Atualiza ao voltar
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Aqui está a secção real de notificações (3 recentes + botão para todas)
  Widget _buildNotificationsSection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notificacoes')
        .orderBy('hora', descending: true)
        .limit(3)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Notificações Recentes'),
            if (docs.isEmpty)
              const Text('Não há notificações recentes.')
            else
              Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Podes ajustar a forma como pegas o ícone; aqui uso um ícone fixo
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificacaoItem(
                      icone: Icons.notifications, // ou outro ícone que prefiras
                      titulo: data['titulo'] ?? 'Sem título',
                      mensagem: data['mensagem'] ?? '',
                      hora: data['hora'] != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format((data['hora'] as Timestamp).toDate())
                          : '',
                    ),
                  );
                }).toList(),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificacoesWidget(
                        nomeUtilizador: widget.nomeUtilizador,
                      ),
                    ),
                  );
                },
                child: const Text('Ver todas as notificações'),
              ),
            ),
          ],
        ),
      );
    },
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

  Widget _buildUpcomingReservationsSection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
      .collection('reservas')
      .where('utilizador', isEqualTo: widget.nomeUtilizador)
      .orderBy('data', descending: false)
      .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;

      // Filtrar só reservas com data futura (opcional, mas faz sentido)
      final proximasReservas = docs.where((doc) {
        final data = (doc['data'] as Timestamp).toDate();
        return data.isAfter(DateTime.now());
      }).toList();

      if (proximasReservas.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Não tens reservas próximas.'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Próximas Reservas'),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: proximasReservas.length,
            itemBuilder: (context, index) {
              final doc = proximasReservas[index];
              final dataTimestamp = doc['data'] as Timestamp;
              final dataDate = dataTimestamp.toDate();

              String dataFormatada = DateFormat('dd/MM/yyyy').format(dataDate);
              String titulo = doc['titulo'] ?? 'Reserva';
              String horario = doc['horario'] ?? '';
              String status = doc['status'] ?? '';
              Color cor = Colors.grey; // cor default

              // Supondo que guardas a cor como string hex (ex: '#FF0000')
              if (doc['cor'] != null) {
                try {
                  cor = Color(int.parse(doc['cor'].toString().replaceFirst('#', '0xff')));
                } catch (e) {
                  // Se falhar, mantém cor default
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(titulo),
                  subtitle: Text('$dataFormatada às $horario'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}


  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
