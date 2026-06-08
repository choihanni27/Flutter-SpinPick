import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_pick/database/drift_database.dart';
import 'package:spin_pick/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

  runApp(
    MaterialApp(
      home: HomeScreen(),
    ),
  );
}