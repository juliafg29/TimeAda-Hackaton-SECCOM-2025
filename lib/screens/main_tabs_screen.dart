import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'documents_screen.dart';
import 'login_screen.dart';
import '../database/database_helper.dart';
import '../models/client.dart';

class MainTabsScreen extends StatefulWidget {
  final String attorneyName;

  const MainTabsScreen({Key? key, required this.attorneyName}) : super(key: key);

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClients();

    // Atualizar lista de clientes quando mudar de tab
    _tabController.addListener(() {
      if (_tabController.index == 1) { // Tab de documentos
        _loadClients();
      }
    });
  }

  Future<void> _loadClients() async {
    final clients = await DatabaseHelper.instance.getAllClients();
    setState(() {
      _clients = clients;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fechar o diálogo
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'ESCRITÓRIO DE ADVOCACIA',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              'Advogado: ${widget.attorneyName[0].toUpperCase()}${widget.attorneyName.substring(1).toLowerCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar Usuário',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'CLIENTES',
            ),
            Tab(
              icon: Icon(Icons.description_outlined),
              text: 'DOCUMENTOS',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(
            attorneyName: widget.attorneyName,
            onClientsChanged: _loadClients,
          ),
          DocumentsScreen(clients: _clients),
        ],
      ),
    );
  }
}