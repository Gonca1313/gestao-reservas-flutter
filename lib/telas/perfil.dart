import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // para kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alterar_password_page.dart';
import 'relatarproblema.dart';
import 'detalhes.dart';
import 'notificacoes.dart';
import 'login_registo.dart';
import 'home.dart';
import 'minhasreservas.dart';

class PerfilWidget extends StatefulWidget {
  final String nomeUtilizador;

  const PerfilWidget({super.key, required this.nomeUtilizador});

  static String routeName = 'Perfil';
  static String routePath = '/perfil';

  @override
  State<PerfilWidget> createState() => _PerfilWidgetState();
}

class _PerfilWidgetState extends State<PerfilWidget> {
  Uint8List? _imageData;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc['nome'] ?? '';
            _userEmail = doc['email'] ?? user.email!;
            _isLoading = false;
          });
        } else {
          setState(() {
            _userName = 'Utilizador';
            _userEmail = user.email ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do utilizador: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 600);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageData = bytes;
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = pickedFile;
            _imageData = null;
          });
        }
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  void _showPickOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmara'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  String getInitials(String name) {
    final names = name.split(' ');
    String initials = '';
    for (var part in names.take(2)) {
      if (part.isNotEmpty) initials += part[0];
    }
    return initials.toUpperCase();
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
          _drawerItem(Icons.home, 'Início', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeWidget(nomeUtilizador: _userName)));
          }),
          _drawerItem(Icons.report_problem, 'Relatar Problema', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  RelatarProblemaWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.info, 'Detalhes', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  DetalhesdaSalaEquipamentoWidget(nomeUtilizador: widget.nomeUtilizador)));
          }),
          _drawerItem(Icons.bookmark, 'Minhas Reservas', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  MinhasReservasPage(nomeUtilizador: widget.nomeUtilizador)));
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    ImageProvider? imageProvider;
    if (kIsWeb && _imageData != null) {
      imageProvider = MemoryImage(_imageData!);
    } else if (!kIsWeb && _imageFile != null) {
      imageProvider = FileImage(File(_imageFile!.path));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
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
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.4), // sombra azul suave
        spreadRadius: 3,
        blurRadius: 10,
        offset: const Offset(0, 4), // sombra abaixo
      ),
    ],
    border: Border.all(
      color: Colors.blueAccent,
      width: 4, // largura da borda
    ),
  ),
  child: CircleAvatar(
    radius: 50,
    backgroundColor: Colors.blue,
    backgroundImage: imageProvider,
    child: imageProvider == null
        ? Text(
            getInitials(_userName),
            style: GoogleFonts.inter(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
  ),
),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // cantos arredondados
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    elevation: 5, // sombra forte
    shadowColor: Colors.blueAccent.withOpacity(0.5),
  ),
  onPressed: _showPickOptionsDialog,
  icon: const Icon(Icons.edit, size: 20),
  label: const Text('Alterar Foto', style: TextStyle(fontSize: 16)),
),
                  const SizedBox(height: 12),
                  Text(_userName, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(_userEmail, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildAccountInfo(_userName, _userEmail),
            const SizedBox(height: 24),
            _buildSecuritySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String userName, String userEmail) {
    return Card(
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20), // mais arredondado
  ),
  elevation: 6, // maior elevação para sombra mais forte
  shadowColor: Colors.blueAccent.withOpacity(0.3), // sombra com cor suave
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações da Conta',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _infoItem(Icons.person, 'Nome', userName),
        _infoItem(Icons.email, 'Email', userEmail),
      ],
    ),
  ),
);
}

  Widget _infoItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(color: Colors.grey[600])),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  elevation: 6,
  shadowColor: Colors.blueAccent.withOpacity(0.3),
  child: ListTile(
    leading: const Icon(Icons.lock, color: Colors.blue),
    title: Text('Alterar Password', style: GoogleFonts.inter(fontSize: 16)),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AlterarPasswordPage()),
      );
    },
  ),
);
}
}