import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'restablecercontraseña.dart';

class OlvidoContrasenaScreen extends StatefulWidget {
  @override
  _OlvidoContrasenaScreenState createState() => _OlvidoContrasenaScreenState();
}

class _OlvidoContrasenaScreenState extends State<OlvidoContrasenaScreen> {
  final TextEditingController usernameController = TextEditingController();

  Future<bool> usuarioExiste(String username) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/users/check-existence'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({
        "username": username,
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody[
          "exists"]; // Asumiendo que el campo en la respuesta se llama 'exists' y es un booleano
    } else {
      print('Error al verificar usuario: ${response.body}');
      return false;
    }
  }

  Future<void> solicitarRestablecimiento(String username) async {
    final response = await http.post(
      Uri.parse(
          'https://api2.parkingtalcahuano.cl/reset-password/?username=$username'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Se ha enviado un correo para restablecer tu contraseña. Por favor revisa tu bandeja de entrada.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Error al solicitar restablecimiento: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Hubo un error al solicitar el restablecimiento. Por favor intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olvido de contraseña'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Olvidé mi contraseña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ingresa tu nombre de usuario para restablecer tu contraseña.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  bool exists = await usuarioExiste(username);
                  if (exists) {
                    solicitarRestablecimiento(username);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestablecerContrasenaScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('El nombre de usuario no existe.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, ingresa un nombre de usuario válido.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Enviar correo'),
            ),
          ],
        ),
      ),
    );
  }
}
