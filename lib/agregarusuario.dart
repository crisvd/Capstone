import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';
import 'tabs.dart';

class AgregarUsuarioScreen extends StatefulWidget {
  @override
  _AgregarUsuarioScreenState createState() => _AgregarUsuarioScreenState();
}

class _AgregarUsuarioScreenState extends State<AgregarUsuarioScreen> {
  // Variables for input fields
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _correoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        final lightTheme = ThemeData.light();
        final darkTheme = ThemeData.dark();

        final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

        return Theme(
          data: theme, // Apply the theme to this screen
          child: Scaffold(
            appBar: AppBar(
              title: Text('Invitar Amigos'),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),

                  SizedBox(height: 20),

                  // Email field
                  TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(labelText: 'Correo Electrónico'),
                  ),

                  SizedBox(height: 20),

                  // Message box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Querido amig@ de Parking App, te invito a unirte a nuestra comunidad!',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Invite friend button
                  ElevatedButton(
                    onPressed: () {
                      // Show a snackbar with "Próximamente" message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Funcionalidad Próximamente Disponible'),
                          duration: Duration(seconds: 2), // Duration for which the snackbar is displayed
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Blue color
                      onPrimary: Colors.white, // White text
                    ),
                    child: Text('Invitar Amigo'),
                  ),
                ],
              ),
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks.
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }
}
