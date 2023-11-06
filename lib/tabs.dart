import 'package:flutter/material.dart';
import 'inicio.dart';
import 'maps.dart';
import 'agregarusuario.dart';
import 'agregarvehiculo.dart';
import 'listarvehiculos.dart';
import 'recargar.dart';
import 'consultarsaldo.dart';
import 'configuracion.dart';
import 'reservar.dart';
import 'cerrarsesion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'soporte.dart';


Future<Map<String, dynamic>> fetchDataAndStoreData(int userId) async {
  try {
    final response = await http.get(Uri.parse(
        'https://api2.parkingtalcahuano.cl/users/$userId')); // Include the actual user ID

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // You can also return the parsed JSON data
      return jsonData;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error al cargar datos: $e');
    // Handle or rethrow the exception as needed
    throw e;
  }
}


Future<Map<String, dynamic>?> fetchData(int id) async {
  try {
    final response = await http
        .get(Uri.parse('https://api2.parkingtalcahuano.cl/users/$id'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return jsonData;
    } else {
      print(
          'Error: Failed to load user with statusCode ${response.statusCode}');
      return null; // or throw an exception if you prefer
    }
  } catch (e) {
    print('Error al cargar datos: $e');
    return null; // or throw e;
  }
}

Future<Map<String, dynamic>?> fetchUserData() async {
  int? userId = await fetchUserId();
  if (userId == null) {
    return null;
  }
  return fetchData(userId);
}

Future<int?> fetchUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');
  return userId;
}


Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        FutureBuilder<Map<String, dynamic>?>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return DrawerHeader(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return UserAccountsDrawerHeader(
                accountName: Text(snapshot.data!['username'] ?? 'Unknown'),
                accountEmail: Text(snapshot.data!['email'] ?? 'Unknown'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
              );
            } else {
              return DrawerHeader(child: Text('Error loading user data'));
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InicioScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text('Buscar Estacionamientos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapsScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Invitar Amigos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarUsuarioScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.directions_car),
          title: Text('Agregar Vehículos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarVehiculosScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('Listar Vehículos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListarVehiculosScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.refresh),
          title: Text('Recargar'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecargarDineroScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.monetization_on),
          title: Text('Consultar Saldo'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultarSaldoScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text('Mis Reservas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapsScreen(),
              ),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.live_help),
          title: Text('Soporte'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoporteScreen(),
              ),
            );
          },
        ),
        
        Divider(),
        ListTile(
          leading: Icon(Icons.build),
          title: Text('Configuración'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfiguracionScreen(),
              ),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app), // Cambié el ícono a uno de salida
          title: Text('Cerrar Sesión'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CerrarSesionScreen()),
            );
          },
        ),
      ],
    ),
  );
}
