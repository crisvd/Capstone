import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'main.dart'; // Import your main.dart where DarkModeManager is defined
import 'dark_mode_manager.dart'; 

class ConfiguracionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkModeManager = Provider.of<DarkModeManager>(context); // Use Provider.of

    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();

    final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: theme,
      home: Scaffold(
        
        appBar: AppBar(
          title: Text('Configuración'),
          actions: [
            IconButton(
              icon: Icon(
                darkModeManager.darkModeEnabled
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                darkModeManager.toggleDarkMode();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  darkModeManager.toggleDarkMode();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
                child: Text(
                  darkModeManager.darkModeEnabled
                      ? 'Modo Claro'
                      : 'Modo Oscuro',
                ),
              ),
            ],
          ),
        ),
        drawer: buildDrawer(context),
      ),
    );
  }
}
