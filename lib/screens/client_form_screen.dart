import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/client.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  final int attorneyId;  // Add this parameter

  const ClientFormScreen({
    Key? key,
    this.client,
    required this.attorneyId,  // Make it required
  }) : super(key: key);

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
    }
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id,
        name: _nameController.text,
        phone: _phoneController.text,
      );

      try {
        if (widget.client == null) {
          // Pass both client and attorneyId
          await DatabaseHelper.instance.insertClient(client, widget.attorneyId);
        } else {
          await DatabaseHelper.instance.updateClient(client);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.client == null
                  ? 'Cliente adicionado com sucesso'
                  : 'Cliente atualizado com sucesso'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar cliente'),
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
        title: Text(
          widget.client == null ? 'NOVO CLIENTE' : 'EDITAR CLIENTE',
          style: const TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                      Text(
                        'Informação do Cliente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor insira o nome do cliente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '(00) 00000-0000',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          PhoneInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor insira o telefone do cliente';
                          }
                          final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digitsOnly.length < 10) {
                            return 'Telefone incompleto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCELAR'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _saveClient,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              widget.client == null ? 'ADICIONAR' : 'SALVAR',
                              style: const TextStyle(
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

}


class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';

    if (text.length >= 1) {
      formatted = '(${text.substring(0, text.length > 2 ? 2 : text.length)}';
    }
    if (text.length >= 3) {
      formatted += ') ${text.substring(2, text.length > 7 ? 7 : text.length)}';
    }
    if (text.length >= 8) {
      formatted += '-${text.substring(7, text.length > 11 ? 11 : text.length)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}