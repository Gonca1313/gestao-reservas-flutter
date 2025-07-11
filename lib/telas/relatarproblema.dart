import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'perfil.dart';
import 'detalhes.dart';
import 'login_registo.dart';
import 'notificacoes.dart';
import '../repositorios/notificacoes_repository.dart';
import 'home.dart';
import 'minhasreservas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RelatarProblemaWidget extends StatefulWidget {
  final String nomeUtilizador;

  const RelatarProblemaWidget({super.key, required this.nomeUtilizador});

  static String routeName = 'RelatarProblema';
  static String routePath = '/relatarProblema';

  @override
  State<RelatarProblemaWidget> createState() => _RelatarProblemaWidgetState();
}

class _RelatarProblemaWidgetState extends State<RelatarProblemaWidget> {
  final _formKey = GlobalKey<FormState>();
  String? selectedTipoItem;
  String? selectedUrgencia;
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reportar Problema Técnico',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdownField(
                'Tipo de Item',
                ['Sala', 'Computador', 'Projetor', 'Ar Condicionado', 'Iluminação', 'Outro Equipamento'],
                (value) => setState(() => selectedTipoItem = value),
              ),
              const SizedBox(height: 16),
              _buildTextField('Localização', _localController),
              const SizedBox(height: 16),
              _buildTextField('Descrição do Problema', _descricaoController, maxLines: 5),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Urgência',
                ['Baixa - Pode aguardar', 'Média - Atenção necessária', 'Alta - Urgente'],
                (value) => setState(() => selectedUrgencia = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Submeter Relatório',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: null,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(border: InputBorder.none),
            validator: (value) => value == null ? 'Por favor selecione uma opção' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }

  void _submitReport() async {
  if (_formKey.currentState?.validate() ?? false) {
    final problema = {
      'tipoItem': selectedTipoItem,
      'localizacao': _localController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'urgencia': selectedUrgencia,
      'dataHora': Timestamp.now(),
    };

    try {
      // Guardar o problema reportado
      await FirebaseFirestore.instance.collection('problemas_reportados').add(problema);

      // Aqui adicionas a notificação no Firestore
      await FirebaseFirestore.instance.collection('notificacoes').add({
        'titulo': 'Problema Relatado',
        'mensagem':
            '🛠️ Tipo: ${selectedTipoItem ?? 'Item'}\n📍 Local: ${_localController.text.trim()}\n📝 Descrição: ${_descricaoController.text.trim()}',
        'hora': Timestamp.now(),
        'tipo': 'problema',
        'utilizador': widget.nomeUtilizador,
      });

      // Adicionar notificação local ou do sistema próprio (se quiseres manter)
      NotificacoesRepository().adicionarNotificacao({
        'icone': Icons.warning_amber_rounded,
        'titulo': 'Problema Reportado',
        'mensagem':
            'Tipo: ${selectedTipoItem ?? 'Item'}\nLocal: ${_localController.text.trim()}\nDescrição: ${_descricaoController.text.trim()}',
        'hora': 'agora',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório enviado com sucesso!')),
      );

      _formKey.currentState?.reset();
      setState(() {
        selectedTipoItem = null;
        selectedUrgencia = null;
        _localController.clear();
        _descricaoController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao submeter: $e')),
      );
    }
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeWidget(nomeUtilizador: widget.nomeUtilizador)));
            }),
          _drawerItem(Icons.person, 'Perfil', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  PerfilWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.info, 'Detalhes', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  DetalhesdaSalaEquipamentoWidget(nomeUtilizador: widget.nomeUtilizador)));
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
}
