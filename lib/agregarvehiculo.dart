import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'listarvehiculos.dart';

class AgregarVehiculosScreen extends StatefulWidget {
  @override
  _AgregarVehiculosScreenState createState() => _AgregarVehiculosScreenState();
}

class _AgregarVehiculosScreenState extends State<AgregarVehiculosScreen> {
  // Variables for input fields
  TextEditingController _marcaController = TextEditingController();
  TextEditingController _modeloController = TextEditingController();
  TextEditingController _anioController = TextEditingController();
  TextEditingController _placaController = TextEditingController();

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  bool validarPatente(String patente) {
    return patente.length == 6;
  }

  Future<void> agregarVehiculo() async {
    final apiUrl = Uri.parse('https://api2.parkingtalcahuano.cl/cars/');
    int? userId = await fetchUserId();

    if (userId == null) {
      print("Error: No se pudo obtener el ID del usuario.");
      return;
    }

    if (!validarPatente(_placaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La patente ingresada no es válida")),
      );
      return;
    }

    final body = {
      "user_id": userId,
      "license_plate": _placaController.text,
      "year": int.tryParse(_anioController.text) ??
          0, // Convierte la cadena a int, usa 0 si no es válido
      "brand": _marcaController.text,
      "model": _modeloController.text,
      "is_active": true,
    
    };

    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );


    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vehículo agregado exitosamente")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListarVehiculosScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al agregar vehículo: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        final theme = darkModeManager.darkModeEnabled
            ? ThemeData.dark()
            : ThemeData.light();

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Agregar Vehículo'),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _marcaController,
                    decoration: InputDecoration(labelText: 'Marca'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _modeloController,
                    decoration: InputDecoration(labelText: 'Modelo'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _anioController,
                    decoration: InputDecoration(labelText: 'Año'),
                    keyboardType: TextInputType.number, // Solo números
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _placaController,
                    decoration: InputDecoration(labelText: 'Patente'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: agregarVehiculo,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Agregar Vehículo'),
                  ),
                ],
              ),
            ),
            drawer: buildDrawer(
                context), // Asegúrate de tener esta función definida
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placaController.dispose();
    super.dispose();
  }
}
