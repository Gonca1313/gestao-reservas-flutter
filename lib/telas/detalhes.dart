import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'perfil.dart';
import 'relatarproblema.dart';
import 'login_registo.dart';
import 'notificacoes.dart';
import 'home.dart';
import 'minhasreservas.dart';

class DetalhesdaSalaEquipamentoWidget extends StatefulWidget {
  final bool showDrawer;
  final String nomeUtilizador;

  const DetalhesdaSalaEquipamentoWidget({super.key, this.showDrawer = true, required this.nomeUtilizador});

  @override
  State<DetalhesdaSalaEquipamentoWidget> createState() => _DetalhesdaSalaEquipamentoWidgetState();
}

class _DetalhesdaSalaEquipamentoWidgetState extends State<DetalhesdaSalaEquipamentoWidget> {
  final List<Map<String, dynamic>> salas = [
    {
      'nome': 'Sala de Reuniões A',
      'localizacao': 'Edifício Principal, 2º Andar',
      'descricao': 'Capacidade para 8 pessoas. Projetor incluído.',
      'capacidade': 8,
      'tipo': 'Reunião',
      'wifi': 'Disponível',
      'climatizacao': 'Sim',
      'equipamentos': [
        {'nome': 'Projetor', 'icon': Icons.videocam},
        {'nome': 'Quadro Branco', 'icon': Icons.border_color},
      ],
      'imagemAsset': 'assets/sala1.png',
      'disponivel': true,
    },
    {
      'nome': 'Sala de Conferências B',
      'localizacao': 'Edifício Anexo, 1º Andar',
      'descricao': 'Capacidade para 20 pessoas. Equipado com sistema de áudio.',
      'capacidade': 20,
      'tipo': 'Conferência',
      'wifi': 'Disponível',
      'climatizacao': 'Sim',
      'equipamentos': [
        {'nome': 'Sistema de Som', 'icon': Icons.speaker},
        {'nome': 'Microfone', 'icon': Icons.mic},
        {'nome': 'Computador Integrado', 'icon': Icons.desktop_windows},
      ],
      'imagemAsset': 'assets/sala2.png',
      'disponivel': true,
    },
    {
      'nome': 'Sala de Reuniões C',
      'localizacao': 'Edifício Principal, 3º Andar',
      'descricao': 'Sala equipada para reuniões de equipa até 15 pessoas, com videoconferência e quadro branco.',
      'capacidade': 15,
      'tipo': 'Reunião',
      'wifi': 'Disponível',
      'climatizacao': 'Sim',
      'equipamentos': [
        {'nome': 'Videoconferência', 'icon': Icons.videocam},
        {'nome': 'Quadro Branco', 'icon': Icons.border_color},
        {'nome': 'Televisor', 'icon': Icons.tv},
        {'nome': 'Computador Integrado', 'icon': Icons.desktop_windows},
      ],
      'imagemAsset': 'assets/sala3.png',
      'disponivel': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes das Salas',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        automaticallyImplyLeading: false, // Desliga o botão padrão
  leading: Builder(
  builder: (context) {
    return widget.showDrawer
        ? IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )
        : IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          );
  },
),

),
      drawer: widget.showDrawer ? _buildDrawer() : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: salas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final sala = salas[index];
            return _buildSalaCard(sala);
          },
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
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.person, 'Perfil', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  PerfilWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.report_problem, 'Relatar Problema', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  RelatarProblemaWidget(nomeUtilizador: widget.nomeUtilizador)));
            }),
          _drawerItem(Icons.bookmark, 'Minhas Reservas', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  MinhasReservasPage(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.info, 'Notificações', () {
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

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: GoogleFonts.inter(fontSize: 16)),
      onTap: onTap,
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

  Widget _buildSalaCard(Map<String, dynamic> sala) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(sala['imagemAsset'], sala['disponivel']),
            const SizedBox(height: 16),
            _buildInfoSection(sala),
            const SizedBox(height: 16),
            _buildDetailsSection(sala),
            const SizedBox(height: 16),
            _buildEquipmentSection(sala['equipamentos']),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath, bool disponivel) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            assetPath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: disponivel ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  disponivel ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  disponivel ? 'Disponível' : 'Indisponível',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> sala) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sala['nome'],
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(sala['localizacao'], style: const TextStyle(fontSize: 16)),
          ],
        ),
        const Divider(height: 24, thickness: 1, color: Colors.grey),
        Text(
          sala['descricao'],
          style: GoogleFonts.inter(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> sala) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _detailItem(Icons.people, 'Capacidade: ${sala['capacidade']} pessoas'),
        _detailItem(Icons.meeting_room, 'Tipo: ${sala['tipo']}'),
        _detailItem(Icons.wifi, 'Wi-Fi: ${sala['wifi']}'),
        _detailItem(Icons.ac_unit, 'Climatização: ${sala['climatizacao']}'),
      ],
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection(List<dynamic> equipamentos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipamentos Disponíveis',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...equipamentos.map<Widget>((equip) {
          return _detailItem(equip['icon'], equip['nome']);
        }).toList(),
      ],
    );
  }
}
