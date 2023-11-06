import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'recargar.dart';
import 'dark_mode_manager.dart';
import 'tabs.dart'; // Assuming 'tabs.dart' defines the 'buildDrawer' method

class ConsultarSaldoScreen extends StatelessWidget {
  const ConsultarSaldoScreen({Key? key}) : super(key: key);

  Future<int?> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<Map<String, dynamic>> fetchWallet(int userId) async {
    final url = Uri.parse('https://api2.parkingtalcahuano.cl/wallets/$userId');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to load wallet with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        return Theme(
          data: darkModeManager.darkModeEnabled
              ? ThemeData.dark()
              : ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Consultar Saldo'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<int?>(
                future: fetchUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.data == null) {
                    return const Center(child: Text("User ID not found"));
                  }

                  // If we have the user ID, we fetch the wallet
                  final userId = snapshot.data!;
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchWallet(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        final balance = data['balance']?.toDouble() ?? 0.0;

                        return _buildBalanceDisplay(balance, context);
                      } else {
                        return const Center(
                            child: Text("No wallet data available"));
                      }
                    },
                  );
                },
              ),
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }

  Widget _buildBalanceDisplay(double balance, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Saldo Disponible:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$$balance',
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 20),
        const Text(
          'Última transacción:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Compra en Estacionamiento XYZ',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[100],
          ),
          child: const Center(
            child: Text(
              'Historial de Transacciones',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecargarDineroScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text(
            'Recargar',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
