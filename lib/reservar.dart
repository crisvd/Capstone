import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'maps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParkingSpace {
  final String id;
  final LatLng location;
  final String name;
  final String description;
  final String locationAddress; // Dirección detallada del estacionamiento
  final bool state;

  ParkingSpace(this.id, this.location, this.name, this.description,
      this.locationAddress, this.state);
}

class ReservarScreen extends StatefulWidget {
  final String id;
  ReservarScreen({required this.id});

  @override
  _ReservarScreenState createState() => _ReservarScreenState();
}

class _ReservarScreenState extends State<ReservarScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fechaController = TextEditingController();
  TextEditingController horaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  String? fecha;
  String? hora;
  String? ubicacion;
  ParkingSpace? parkingSpace;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    loadParkingSpace();
  }

  Future<ParkingSpace?> fetchData(String id) async {
    try {
      final response = await http
          .get(Uri.parse('https://api1.marweg.cl/parking_spaces/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ParkingSpace(
            data['id'],
            LatLng(data['latitude'], data['longitude']),
            data['name'],
            data['description'],
            data['location'],
            data['state']);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      return null;
    }
  }

  Future<void> loadParkingSpace() async {
    ParkingSpace? fetchedParkingSpace = await fetchData(widget.id);
    if (fetchedParkingSpace != null) {
      setState(() {
        parkingSpace = fetchedParkingSpace;
        ubicacionController.text = parkingSpace!.location.toString();
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null && time != selectedTime) {
      // Comprobar si la hora seleccionada está dentro del rango permitido
      if (time.hour >= 8 && time.hour < 19) {
        setState(() {
          selectedTime = time;
          horaController.text =
              '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
        });
      } else {
        // Mostrar un mensaje si se selecciona una hora fuera del rango permitido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Por favor, seleccione una hora entre las 8:00 y las 19:00'),
          ),
        );
      }
    }
  }

  Future<void> updateParkingSpaceState(String id, bool newState) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://api1.marweg.cl/parking_spaces/$id/update_state?new_state=$newState'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Estado del estacionamiento actualizado con éxito.');
      } else {
        print('Error al actualizar el estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }

  Future<void> createReservation(Future<int?> userIdFuture,
      String parkingSpotId, String startTime, String endTime) async {
    try {
      // Obtener userId
      int? userId = await userIdFuture;
      if (userId == null) {
        print('Error: User ID is null');
        return;
      }

      final response = await http.post(
        Uri.parse('https://api2.parkingtalcahuano.cl/reservations/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'user_id': userId,
          'parking_spot_id': parkingSpotId,
          'start_time': startTime,
          'end_time': endTime
        }),
      );

      print(userId);
      print(parkingSpotId);
      print(startTime);
      print(endTime);

      if (response.statusCode == 200) {
        print('Reservación creada con éxito.');
      } else {
        print('Error al crear la reservación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    return userId;
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        fechaController.text =
            '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Reservar Estacionamiento - ${parkingSpace?.name ?? "Cargando..."}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (parkingSpace != null) ...[
                Text('Nombre: ${parkingSpace!.name}'),
                Text('Descripción: ${parkingSpace!.description}'),
                Text('Ubicación: ${parkingSpace!.locationAddress}'),
                SizedBox(height: 20),
              ],
              ListTile(
                title: Text(
                    'Fecha de Reserva: ${fechaController.text.isEmpty ? "Seleccionar fecha" : fechaController.text}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(
                  selectedTime != null
                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Seleccione una hora',
                ),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              // Verificar si el estado del estacionamiento permite la reserva
              if (parkingSpace != null && parkingSpace!.state)
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isValidDate(fechaController.text) &&
                          isValidTime(horaController.text)) {
                        _formKey.currentState!.save();
                        // Cambiar el estado del estacionamiento a no disponible
                        updateParkingSpaceState(widget.id, false);
                        createReservation(fetchUserId(), parkingSpace!.id,
                            horaController.text, horaController.text);
                        // Mensaje de éxito con color verde y datos simplificados
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Reserva exitosa: ${fechaController.text}, ${horaController.text}'),
                            backgroundColor:
                                Colors.green, // Color del fondo del SnackBar
                          ),
                        );

                        // Espera 4 segundos antes de redireccionar
                        Future.delayed(Duration(seconds: 3), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapsScreen(),
                            ),
                          );
                        });
                      } else {
                        // Mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, introduzca una fecha y hora válidas.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Reservar'),
                ),
              // Mostrar un mensaje si el estacionamiento no está disponible
              if (parkingSpace != null && !parkingSpace!.state)
                Center(
                  child: Text(
                    'Este estacionamiento no está disponible para reservar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

bool isValidDate(String input) {
  final RegExp regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  return regex.hasMatch(input);
}

bool isValidTime(String input) {
  final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
  return regex.hasMatch(input);
}
