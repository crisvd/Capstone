import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ListarReservasScreen extends StatefulWidget {
  @override
  _ListarReservasScreenState createState() => _ListarReservasScreenState();
}

class _ListarReservasScreenState extends State<ListarReservasScreen> {
  List<Reserva> reservas = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    int? userId = await fetchUserId();
    if (userId != null) {
      fetchReservationData(userId);
    }
  }

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> fetchReservationData(int userId) async {
    final apiUrl =
        Uri.parse('https://api2.parkingtalcahuano.cl/reservations/all');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reservas = data
              .map((item) => Reserva.fromJson(item))
              .where((reserva) => reserva.userId == userId && reserva.isActive)
              .toList();
        });
      } else {
        print('Failed to load reservation data');
      }
    } catch (exception) {
      print('Exception while fetching reservation data: $exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listar Reservas')),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Lugar de Estacionamiento')),
            DataColumn(label: Text('Hora de Inicio')),
            DataColumn(label: Text('Hora de Fin')),
            DataColumn(label: Text('Acción')),
          ],
          rows: reservas.map((reserva) {
            return DataRow(cells: [
              DataCell(Text('${reserva.id}')),
              DataCell(Text(reserva.parkingSpotId)),
              DataCell(Text(reserva.startTime)),
              DataCell(Text(reserva.endTime)),
              DataCell(ElevatedButton(
                child: Text('Cancelar reserva'),
                style: ElevatedButton.styleFrom(
                  primary: Colors
                      .red, // Esto establece el color de fondo del botón a rojo
                  onPrimary: Colors
                      .white, // Esto establece el color del texto a blanco
                ),
                onPressed: () {
                  cancelarReserva(reserva.id);
                  setState(() {
                    reservas.remove(reserva);
                  });
                },
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void cancelarReserva(int reservaId) {
    // Aquí debes agregar la lógica para realizar un API call y cancelar la reserva
    final apiUrl = Uri.parse(
        'https://api2.parkingtalcahuano.cl/reservations/cancel/$reservaId');
    http.post(apiUrl).then((response) {
      if (response.statusCode == 200) {
        print('Reserva cancelada con éxito');
      } else {
        print('Error al cancelar la reserva');
      }
    }).catchError((error) {
      print('Error al cancelar la reserva: $error');
    });
  }
}

class Reserva {
  final int id;
  final int userId;
  final String parkingSpotId;
  final String startTime;
  final String endTime;
  final bool isActive;

  Reserva({
    required this.id,
    required this.userId,
    required this.parkingSpotId,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      userId: json['user_id'],
      parkingSpotId: json['parking_spot_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isActive: json['is_active'],
    );
  }
}
