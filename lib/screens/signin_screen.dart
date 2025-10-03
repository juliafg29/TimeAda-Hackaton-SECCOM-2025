import 'package:flutter/material.dart';
import '../models/attorney.dart';
import '../database/database_helper.dart';

class SigninScreen extends StatefulWidget {
  final String initialName;
  final Function(int id, String name) onSignedUp;

  const SigninScreen({
    Key? key,
    required this.initialName,
    required this.onSignedUp,
  }) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _n8nUrlController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final attorney = Attorney(
          name: _nameController.text,
          n8nWebhookUrl: _n8nUrlController.text,
          phone: int.tryParse(_phoneController.text),
        );

        final id = await DatabaseHelper.instance.insertAttorney(attorney);
        widget.onSignedUp(id, attorney.name);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar conta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CRIAR CONTA',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w300),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                      value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Campo obrigatório';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Digite apenas números';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _n8nUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL do Webhook n8n',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (value) =>
                      value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('CRIAR CONTA'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _n8nUrlController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}