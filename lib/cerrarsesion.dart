import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class CerrarSesionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerrar Sesión'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            mostrarDialogoCerrarSesion(context);
          },
          child: Text('Cerrar Sesión'),
        ),
      ),
    );
  }

  Future<void> mostrarDialogoCerrarSesion(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿Cerrar Sesión?'),
          content: Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Elimina el token de autenticación antes de cerrar la sesión.
                await eliminarTokenDeAutenticacion(context);

                // Cierra la sesión y vuelve a la pantalla de inicio de sesión o a donde sea necesario.
                Navigator.of(context).pop(); // Cierra el diálogo
                // En lugar de Navigator.of(context).pop(); usa el método pushAndRemoveUntil para asegurarte de que se redirige a Login
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              },
              child: Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarTokenDeAutenticacion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('auth_token');
      prefs.remove('user_id');
    } catch (e) {
      print('Error al eliminar el token de autenticación: $e');
      // Maneja cualquier error que pueda ocurrir al eliminar el token de autenticación.
    }
  }
}
