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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DNFBitBitv2',
        scaffoldBackgroundColor: Color(0xFFFDF8F8),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,  // 글자/아이콘 색
          elevation: 0,  // 그림자 없애기
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
      ),
      home: HomeScreen(),
    ),
  );
}