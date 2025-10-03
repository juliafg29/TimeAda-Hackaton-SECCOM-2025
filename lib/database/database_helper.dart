import 'dart:async';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/attorney.dart';
import '../models/client.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Use sqflite for mobile platforms
        return await openDatabase(
          'law_office.db',
          version: 1,
          onCreate: _createDB,
        );
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          'law_office.db',
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _createDB,
          ),
        );
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE clients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE attorney (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          n8n_webhook_url TEXT NOT NULL,
          phone INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE attorney_clientes_relationship (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          attorney_id INTEGER NOT NULL,
          client_id INTEGER NOT NULL,
          FOREIGN KEY (attorney_id) REFERENCES attorney (id) ON DELETE CASCADE,
          FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE
        )
      ''');
    } catch (e) {
      rethrow;
    }
  }

  // ------------------------
  // clientes

  Future<int> insertClient(Client client, int attorneyId) async {
    final db = await database;

    final existingClient = await db.query(
      'clients',
      where: 'phone = ?',
      whereArgs: [client.phone],
    );

    late int clientId;

    if (existingClient.isEmpty) {
      clientId = await db.insert('clients', client.toMap());
    } else {
      clientId = existingClient.first['id'] as int;
    }

    await db.insert('attorney_clientes_relationship', {
      'attorney_id': attorneyId,
      'client_id': clientId,
    });

    return clientId;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final result = await db.query('clients', orderBy: 'name ASC');
    return result.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------
  // advogados

  Future<int> insertAttorney(Attorney attorney) async {
    final db = await database;
    return await db.insert('attorney', attorney.toMap());
  }

  Future<List<Attorney>> getAllAttorneys() async {
    final db = await database;
    final result = await db.query('attorney', orderBy: 'name ASC');
    return result.map((map) => Attorney.fromMap(map)).toList();
  }

  Future<int> updateAttorney(Attorney attorney) async {
    final db = await database;
    return await db.update(
      'attorney',
      attorney.toMap(),
      where: 'id = ?',
      whereArgs: [attorney.id],
    );
  }

  Future<int> deleteAttorney(int id) async {
    final db = await database;
    return await db.delete(
      'attorney',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ------------------------
  // relacionamento advogado-clientes

  Future<int> insertAttorneyClientRelationship(
      int attorneyId, int clientId) async {
    final db = await database;
    return await db.insert('attorney_clientes_relationship', {
      'attorney_id': attorneyId,
      'client_id': clientId,
    });
  }

  Future<int> deleteAttorneyClientRelationship(
      int attorneyId, int clientId) async {
    final db = await database;
    return await db.delete(
      'attorney_clientes_relationship',
      where: 'attorney_id = ? AND client_id = ?',
      whereArgs: [attorneyId, clientId],
    );
  }

  Future<List<Client>> getClientsForAttorney(int attorneyId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.id, c.name, c.phone
      FROM clients c
      JOIN attorney_clientes_relationship acr ON c.id = acr.client_id
      WHERE acr.attorney_id = ?
      ORDER BY c.name ASC
    ''', [attorneyId]);
    return result.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> removeClientFromAttorney(int attorneyId, int clientId) async {
    final db = await database;

    await deleteAttorneyClientRelationship(attorneyId, clientId);

    final remainingRelationships = await db.query(
      'attorney_clientes_relationship',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );

    if (remainingRelationships.isEmpty) {
      return await deleteClient(clientId);
    }

    return 1;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
