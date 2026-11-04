/// Configuração do MaterialApp e navegação entre telas.
import 'package:flutter/material.dart';

import 'features/localizacoes/presentation/screens/tela_coleta.dart';
import 'features/localizacoes/presentation/screens/tela_localizacoes.dart';
import 'features/localizacoes/presentation/screens/tela_mapa.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localizações',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaColeta(),
        '/historico': (context) => const TelaLocalizacoes(),
        '/mapa': (context) => const TelaMapa(),
      },
    );
  }
}
