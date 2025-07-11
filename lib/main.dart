import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';  // Import necessário
import 'telas/login_registo.dart'; // Certifica-te que o nome do ficheiro está correto
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Reservas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // Aqui adicionas a configuração para português de Portugal
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'PT'),  // Português de Portugal
      ],
      locale: const Locale('pt', 'PT'),  // Força o uso do português de Portugal

      home: LoginRegistoWidget(), // Agora o login é a tela inicial
    );
  }
}
