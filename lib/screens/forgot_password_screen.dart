// Arquivo: lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String _message = '';
  bool _isError = false;

  void _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _loading = true; _message = ''; _isError = false; });
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.sendPasswordResetCode(_emailController.text.trim());
      if (!mounted) return;
      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: _emailController.text.trim())),
        );
      } else {
        setState(() {
          _message = result['message'];
          _isError = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Insira o seu email para enviarmos um código de recuperação.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Por favor, insira o seu email' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_message.isNotEmpty)
                    Text(_message, textAlign: TextAlign.center, style: TextStyle(color: _isError ? Colors.red : Colors.green)),
                  const SizedBox(height: 16),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(onPressed: _sendResetCode, child: const Text('Enviar Código')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}