import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginRegistoWidget extends StatefulWidget {
  const LoginRegistoWidget({super.key});

  static String routeName = 'loginregisto';
  static String routePath = '/loginregisto';

  @override
  State<LoginRegistoWidget> createState() => _LoginRegistoWidgetState();
}

class _LoginRegistoWidgetState extends State<LoginRegistoWidget> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();

  bool isLogin = true;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 253, 252, 252),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        isLogin ? 'Login' : 'Registo',
        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
  padding: const EdgeInsets.all(24.0),
  child: Card(
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // seu conteúdo atual aqui
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icon.png', height: 150),
                  const SizedBox(height: 24),
                  Text(
                    isLogin ? 'Bem-vindo de volta!' : 'Crie a sua conta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
const SizedBox(height: 32),


                  // Campos adicionais para registo
                  if (!isLogin) ...[
                    _buildInputField('Nome', _nomeController, TextInputType.name),
                    const SizedBox(height: 16),
                    _buildInputField('Sobrenome', _sobrenomeController, TextInputType.name),
                    const SizedBox(height: 16),
                  ],

                  _buildInputField('Email', _emailController, TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'Password',
                    _passwordController,
                    TextInputType.visiblePassword,
                    isPassword: true,
                    inputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 8),

                  if (isLogin)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () async {
        if (_emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insira o seu email para recuperar a password'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email de recuperação enviado', style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: Colors.blue,
            ),
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${e.message}', style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text(
        'Esqueci-me da password',
        style: GoogleFonts.inter(color: Colors.blue),
      ),
    ),
  ),


                  const SizedBox(height: 16),
                  ElevatedButton(
  onPressed: _submit,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.indigoAccent,
    elevation: 6,
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    shadowColor: Colors.black.withOpacity(0.3),
  ),
  child: Text(
    isLogin ? 'Entrar' : 'Criar Conta',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  ),
),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        _formKey.currentState?.reset();
                        _emailController.clear();
                        _passwordController.clear();
                        _nomeController.clear();
                        _sobrenomeController.clear();
                        _obscurePassword = true;
                      });
                      _animationController.forward(from: 0);
                    },
                    child: Text(
                      isLogin ? 'Não tem conta? Registe-se' : 'Já tem conta? Faça login',
                      style: GoogleFonts.inter(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    ),
    );
  }
  

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType inputType, {
    bool isPassword = false,
    TextInputAction inputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: inputAction,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }

        if ((label == 'Nome' || label == 'Sobrenome') && value.trim().length < 2) {
          return 'Insira um nome válido';
        }

        if (label == 'Email' && !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
          return 'Insira um email válido';
        }

        if (label == 'Password' && value.length < 6) {
          return 'Mínimo 6 caracteres';
        }

        return null;
      },
    );
  }

  void _submit() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential;

      if (isLogin) {
        userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login efetuado com sucesso', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Guardar nome na Firestore após registo (se quiseres capturar nome do utilizador noutro campo, ajusta aqui)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'nome': _nomeController.text.trim(),
          'sobrenome': _sobrenomeController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conta criada com sucesso', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 🔍 Buscar nome do utilizador da Firestore
      final uid = userCredential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final nome = doc.exists && doc.data()!.containsKey('nome')
          ? doc['nome']
          : userCredential.user!.email ?? 'Utilizador';

      // ✅ Ir para HomeWidget com nome
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeWidget(nomeUtilizador: nome)),
        );
      });
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Utilizador não encontrado';
          break;
        case 'wrong-password':
          message = 'Password incorreta';
          break;
        case 'email-already-in-use':
          message = 'Email já está em uso';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'weak-password':
          message = 'Password fraca';
          break;
        default:
          message = 'Erro: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}