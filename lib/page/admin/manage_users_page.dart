import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path; // 为 path 库添加别名，避免命名冲突
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/password_utils.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(
      documentsDirectory.path,
      'users.db',
    ); // 使用别名调用 path 库的方法
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, fullName TEXT, matricula TEXT, email TEXT, phone TEXT, address TEXT, roleId TEXT, profilePicture TEXT)',
        );
      },
    );
  }

  Future<void> _updateUserPassword(int userId, String newPassword) async {
    try {
      String hashedPassword = PasswordUtils.hashPassword(newPassword);
      await _database.update(
        'users',
        {'password': hashedPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar contraseña: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Usuarios')),
      body: Center(child: Text('Administrar Usuarios Page')),
    );
  }
}
