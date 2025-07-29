// Arquivo: lib/screens/register_screen.dart
// MODIFICADO: Atualiza a lógica de submit para tratar a resposta da API.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _loading = true; _error = ''; });

      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.registerWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso! Faça o login.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _error = result['message'];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // O restante do build continua o mesmo...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(24.0),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('Preencha seus dados', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 24.0),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person_outline)),
                        validator: (val) => val!.isEmpty ? 'Por favor, insira seu nome' : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val!.isEmpty ? 'Por favor, insira um email válido' : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscured,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.textLight),
                            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                          ),
                        ),
                        validator: (val) => val!.length < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        obscureText: _isConfirmPasswordObscured,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.textLight),
                            onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                          ),
                        ),
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 14)),
                        ),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Registrar'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}