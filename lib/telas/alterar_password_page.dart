import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlterarPasswordPage extends StatelessWidget {
  const AlterarPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alterar Password',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Password Atual',
                controller: _currentPasswordController,
                icon: Icons.lock_outline,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Introduza a password atual' : null,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Nova Password',
                controller: _newPasswordController,
                icon: Icons.lock_reset,
                validator: (value) =>
                    value != null && value.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Confirmar Nova Password',
                controller: _confirmPasswordController,
                icon: Icons.lock,
                validator: (value) => value != _newPasswordController.text
                    ? 'Passwords não coincidem'
                    : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Guardar Alterações',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null || user.email == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Utilizador não autenticado', style: GoogleFonts.inter(color: Colors.white)),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final cred = EmailAuthProvider.credential(
                        email: user.email!,
                        password: _currentPasswordController.text.trim(),
                      );

                      try {
                        // Reautenticar utilizador
                        await user.reauthenticateWithCredential(cred);

                        // Atualizar password
                        await user.updatePassword(_newPasswordController.text.trim());

                        // Sucesso
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password alterada com sucesso!', style: GoogleFonts.inter(color: Colors.white)),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } on FirebaseAuthException catch (e) {
                        String errorMsg;

                        switch (e.code) {
                          case 'wrong-password':
                            errorMsg = 'Password atual incorreta.';
                            break;
                          case 'weak-password':
                            errorMsg = 'Nova password é demasiado fraca.';
                            break;
                          case 'requires-recent-login':
                            errorMsg = 'É necessário fazer login novamente.';
                            break;
                          default:
                            errorMsg = 'Erro ao alterar a password: ${e.message}';
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg, style: GoogleFonts.inter(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
