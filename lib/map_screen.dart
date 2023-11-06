import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'reservar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class ParkingSpace {
  final String id;
  final LatLng location;
  final String name;
  final String description;
  final String coordinates;
  final bool state;

  ParkingSpace(
    this.id,
    this.location,
    this.name,
    this.description,
    this.coordinates,
    this.state,
  );
}

class _MapScreenState extends State<MapScreen> {
  LatLng? selectedMarkerLocation;
  Position? currentLocation;

  List<ParkingSpace> parkingSpaceLocations = [];
  List<ParkingSpace> filteredParkingSpaceLocations = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    getCurrentLocation();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('https://api1.marweg.cl/parking_spaces'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<ParkingSpace> parkingSpaces =
            (data as List<dynamic>).map((parkingSpace) {
          return ParkingSpace(
              parkingSpace['id'],
              LatLng(parkingSpace['latitude'], parkingSpace['longitude']),
              parkingSpace['name'],
              parkingSpace['description'],
              parkingSpace['location'],
              parkingSpace['state']);
        }).toList();

        setState(() {
          parkingSpaceLocations = parkingSpaces;
          filteredParkingSpaceLocations = parkingSpaces;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = position;
      });
    } catch (e) {
      print('Error al obtener la ubicación actual: $e');
    }
  }

  void _showMarkerInfo(BuildContext context, ParkingSpace parkingSpace) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isParkingSpaceAvailable = parkingSpace.state;

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información de los lugares de Parking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text('Nombre: ${parkingSpace.name}'),
              Text('Descripcion: ${parkingSpace.description}'),
              Text('Dirección: ${parkingSpace.coordinates}'),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: 'Estado: '),
                    TextSpan(
                      text: isParkingSpaceAvailable
                          ? "Disponible"
                          : "NO Disponible",
                      style: TextStyle(
                        color:
                            isParkingSpaceAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Divider(),
              if (isParkingSpaceAvailable) // Mostrar botón solo si el estacionamiento está disponible
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 20,
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReservarScreen(id: parkingSpace.id),
                        ),
                      );
                    },
                    child: Text('Ocupar Ahora'),
                  ),
                ),
              Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReservarScreen(id: parkingSpace.id),
                      ),
                    );
                  },
                  child: Text('Reservar'),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void filterParkingSpaces(String query) {
    setState(() {
      // Removemos espacios en blanco al principio y al final de la consulta
      String trimmedQuery = query.trim().toLowerCase();
      List<String> queryWords = trimmedQuery.split(' ');

      filteredParkingSpaceLocations =
          parkingSpaceLocations.where((parkingSpace) {
        String lowerCaseName = parkingSpace.coordinates.toLowerCase();

        // Verifica que todas las palabras de la consulta estén presentes en el nombre del estacionamiento
        bool matchesName =
            queryWords.every((word) => lowerCaseName.contains(word));

        bool matchesLocation = parkingSpace.location
            .toString()
            .toLowerCase()
            .contains(trimmedQuery);

        // Devuelve true si el nombre o la ubicación coinciden con la consulta
        return matchesName || matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: (query) {
              filterParkingSpaces(query);
            },
            decoration: InputDecoration(
              labelText: 'Buscar Espacios de Estacionamiento',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              center: currentLocation != null
                  ? LatLng(
                      currentLocation!.latitude, currentLocation!.longitude)
                  : LatLng(-36.714658,
                      -73.114729), // Coordenadas de centro por defecto
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: filteredParkingSpaceLocations
                    .map<Marker>((parkingSpace) => Marker(
                          point: parkingSpace.location,
                          width: 80,
                          height: 80,
                          builder: (context) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarkerLocation = parkingSpace.location;
                              });
                              _showMarkerInfo(context, parkingSpace);
                            },
                            child: Icon(
                              Icons.directions_car,
                              color: selectedMarkerLocation ==
                                      parkingSpace.location
                                  ? Colors.red
                                  : Colors.blue,
                              size: 48.0,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
