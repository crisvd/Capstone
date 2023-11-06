import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SoporteScreen extends StatefulWidget {
  @override
  _SoporteScreenState createState() => _SoporteScreenState();
}

class _SoporteScreenState extends State<SoporteScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _enviarCorreo() {
    final mensaje = _textController.text;

    // Aquí puedes agregar el código para enviar el correo con tu solución preferida.
    // Por ahora, solo mostraremos un mensaje indicando que el correo fue "enviado".
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Mensaje enviado: $mensaje')));
  }

  void _contactarWhatsApp() async {
    const numeroSoporte =
        "1234567890"; // Reemplaza esto con el número real de soporte
    const mensaje = "Hola, necesito ayuda.";

    final url = "https://wa.me/$numeroSoporte?text=${Uri.parse(mensaje)}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Soporte"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Si tienes problemas, escríbenos un mensaje:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje aquí...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Enviar correo a soporte'),
              onPressed: _enviarCorreo,
            ),
            SizedBox(height: 20),
            TextButton(
              child: Text('O contacta por WhatsApp'),
              onPressed: _contactarWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}
