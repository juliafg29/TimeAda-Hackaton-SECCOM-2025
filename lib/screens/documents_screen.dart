// screens/documents_screen.dart
import 'package:flutter/material.dart';
import '../models/client.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class DocumentsScreen extends StatefulWidget {
  final List<Client> clients;

  const DocumentsScreen({Key? key, required this.clients}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actionController = TextEditingController();
  final _n8nUrlController = TextEditingController(
    text: 'https://your-n8n-instance.com/webhook/document',
  );

  Client? _selectedClient;
  String? _fileName;
  Uint8List? _fileBytes;
  bool _isSending = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.first.name;
          _fileBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      _showMessage('Erro ao selecionar arquivo: $e', isError: true);
    }
  }

  Future<void> _sendToN8n() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      _showMessage('Por favor, selecione um cliente', isError: true);
      return;
    }
    if (_fileName == null || _fileBytes == null) {
      _showMessage('Por favor, selecione um documento', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      // Converter bytes para base64
      final base64File = base64Encode(_fileBytes!);

      // Preparar dados para enviar ao n8n
      final data = {
        'client': {
          'id': _selectedClient!.id,
          'name': _selectedClient!.name,
          'phone': _selectedClient!.phone,
        },
        'action': _actionController.text,
        'document': {
          'name': _fileName,
          'content': base64File,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Aqui você fará a chamada real para o n8n
      // Por enquanto, apenas simulando
      await Future.delayed(const Duration(seconds: 2));

      // Exemplo de como enviar (descomente quando tiver o endpoint real):
      /*
      import 'package:http/http.dart' as http;

      final response = await http.post(
        Uri.parse(_n8nUrlController.text),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _showMessage('Documento enviado com sucesso!');
        _clearForm();
      } else {
        _showMessage('Erro ao enviar documento: ${response.statusCode}', isError: true);
      }
      */

      // Simulação de sucesso
      print('Dados para enviar ao n8n: ${json.encode(data)}');
      _showMessage('Documento enviado com sucesso para o n8n!');
      _clearForm();

    } catch (e) {
      _showMessage('Erro: $e', isError: true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedClient = null;
      _fileName = null;
      _fileBytes = null;
      _actionController.clear();
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enviar Documento para n8n',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecione um cliente, documento e ação para processar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Client Selection
                      DropdownButtonFormField<Client>(
                        value: _selectedClient,
                        decoration: const InputDecoration(
                          labelText: 'Selecionar Cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: widget.clients.map((client) {
                          return DropdownMenuItem(
                            value: client,
                            child: Text(client.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedClient = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um cliente';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Action Field
                      TextFormField(
                        controller: _actionController,
                        decoration: const InputDecoration(
                          labelText: 'Ação',
                          hintText: 'Ex: Revisar contrato, Abrir processo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work_outline),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma ação';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Document Upload
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Documento',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_fileName != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _fileName!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _fileName = null;
                                          _fileBytes = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(_fileName == null
                                  ? 'SELECIONAR DOCUMENTO'
                                  : 'ALTERAR DOCUMENTO'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // N8N URL
                      TextFormField(
                        controller: _n8nUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL do Webhook n8n',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a URL do webhook n8n';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Send Button
                      ElevatedButton(
                        onPressed: _isSending ? null : _sendToN8n,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSending
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          'ENVIAR PARA N8N',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
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
    );
  }

  @override
  void dispose() {
    _actionController.dispose();
    _n8nUrlController.dispose();
    super.dispose();
  }
}