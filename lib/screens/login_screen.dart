// Arquivo: lib/screens/login_screen.dart
// MODIFICADO: Agora é um StatefulWidget com lógica de formulário e validação.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _error = '';
  bool _loading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _error = '';
      });

      // Usamos o AuthService para fazer o login
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // O setState é chamado mesmo após uma operação async, então verificamos se o widget ainda está montado.
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _error = 'Email ou senha inválidos. Tente novamente.';
          _loading = false;
        });
      }
      // Se o login for bem-sucedido, o AuthWrapper cuidará da navegação.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                    const Icon(Icons.shield_outlined, size: 60, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text('Bem-vindo ao VitaLog', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Seu assistente de saúde digital.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textLight)),
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.isEmpty ? 'Por favor, insira seu email' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true,
                      validator: (val) => val!.length < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
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
                            child: const Text('Entrar'),
                          ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      child: const Text('Não tem uma conta? Registre-se'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
