// screens/documents_screen.dart
import 'package:flutter/material.dart';
import '../models/client.dart';
import 'dart:convert';
import 'dart:io';
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
  final _clientMessageController = TextEditingController();
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

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Para web, usar path se bytes for null
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null && file.path != null) {
          // Em plataformas desktop/mobile, ler o arquivo do path
          try {
            fileBytes = await File(file.path!).readAsBytes();
          } catch (e) {
            print('Error reading file from path: $e');
          }
        }

        if (fileBytes != null) {
          setState(() {
            _fileName = file.name;
            _fileBytes = fileBytes;
          });

          // Debug logs
          print('Debug - File selected: $_fileName');
          print('Debug - File bytes length: ${_fileBytes?.length}');
          _showMessage('Arquivo selecionado: $_fileName');
        } else {
          _showMessage('Erro: Não foi possível ler o arquivo selecionado',
              isError: true);
        }
      } else {
        print('Debug - No file selected or canceled');
      }
    } catch (e) {
      print('Error in _pickFile: $e');
      _showMessage('Erro ao selecionar arquivo: $e', isError: true);
    }
  }

  Future<void> _sendToN8n() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      _showMessage('Por favor, selecione um cliente', isError: true);
      return;
    }

    // Debug logs
    print('Debug - _fileName: $_fileName');
    print('Debug - _fileBytes length: ${_fileBytes?.length}');
    print('Debug - _fileBytes is null: ${_fileBytes == null}');

    if (_fileName == null || _fileName!.isEmpty) {
      _showMessage('Por favor, selecione um documento', isError: true);
      return;
    }

    if (_fileBytes == null || _fileBytes!.isEmpty) {
      _showMessage(
          'Erro: Arquivo selecionado está vazio. Tente selecionar novamente.',
          isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      // Converter bytes para base64
      final base64File = base64Encode(_fileBytes!);

      // Primeira requisição: Documento principal
      final documentData = {
        'type': 'document',
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

      // Simular primeira requisição
      await Future.delayed(const Duration(seconds: 1));
      print('Primeira requisição - Documento: ${json.encode(documentData)}');
      _showMessage('Documento enviado para processamento...');

      // Segunda requisição: Mensagem do cliente (se preenchida)
      if (_clientMessageController.text.trim().isNotEmpty) {
        final messageData = {
          'type': 'client_message',
          'client': {
            'id': _selectedClient!.id,
            'name': _selectedClient!.name,
            'phone': _selectedClient!.phone,
          },
          'message': _clientMessageController.text.trim(),
          'related_document': _fileName,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Simular segunda requisição
        await Future.delayed(const Duration(seconds: 1));
        print('Segunda requisição - Mensagem: ${json.encode(messageData)}');
        _showMessage('Mensagem do cliente enviada!');
      }

      // Exemplo de como enviar as requisições reais:
      /*
      import 'package:http/http.dart' as http;

      // Primeira requisição - Documento
      final documentResponse = await http.post(
        Uri.parse(_n8nUrlController.text),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(documentData),
      );

      if (documentResponse.statusCode != 200) {
        throw Exception('Erro ao enviar documento: ${documentResponse.statusCode}');
      }

      // Segunda requisição - Mensagem do cliente (se preenchida)
      if (_clientMessageController.text.trim().isNotEmpty) {
        final messageResponse = await http.post(
          Uri.parse(_n8nUrlController.text),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(messageData),
        );

        if (messageResponse.statusCode != 200) {
          print('Aviso: Erro ao enviar mensagem do cliente: ${messageResponse.statusCode}');
        }
      }
      */

      _showMessage('Todas as informações foram enviadas com sucesso!');
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
      _clientMessageController.clear();
    });
    print('Debug - Form cleared');
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
                        'Enviar Documento para Cliente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecione um cliente e documento para processar',
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

                      // Client Message (Optional)
                      TextFormField(
                        controller: _clientMessageController,
                        decoration: const InputDecoration(
                          labelText: 'Mensagem adicional do cliente (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              'Ex: Observações, instruções especiais, comentários do cliente...',
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
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
                                'ENVIAR PARA CLIENTE',
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
    _clientMessageController.dispose();
    _n8nUrlController.dispose();
    super.dispose();
  }
}
