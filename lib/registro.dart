import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:app_parking/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegistroScreen(),
    );
  }
}

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nombreApellidoController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool aceptaTerminos = false;
  bool _obscurePassword = true;

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<bool> checkUserExistence(String username, String email) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/users/check-existence'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody['exists'] ?? false; // Assuming the field is called 'exists' and is boolean.
    } else {
      throw Exception('Error checking user existence');
    }
  }

  Future<int> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    required bool is_active,
  }) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/users/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "email": email,
        "hashed_password": (password), // Using your hash function.
        "role": role,
        "is_active": is_active,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody['id'];
    } else {
      return 0;
    }
  }

  Future<bool> createWallet({required int userId}) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/wallets/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"user_id": userId, "balance": 0}),
    );

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: nombreApellidoController,
                decoration: InputDecoration(labelText: 'Nombre y Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu nombre y apellido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usuarioController,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de usuario.';
                  } else if (value.length < 6) {
                    return 'El nombre de usuario debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Introduce un correo válido.';
                  }
                  return null;
                },
              ),
              _buildPasswordTextField(
                controller: passwordController,
                labelText: 'Contraseña',
              ),
              _buildPasswordTextField(
                controller: confirmPasswordController,
                labelText: 'Confirmar Contraseña',
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: aceptaTerminos,
                    onChanged: (bool? value) {
                      setState(() {
                        aceptaTerminos = value ?? false;
                      });
                    },
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: _mostrarTerminosYCondiciones,
                    child: Text('Acepto los términos y condiciones'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarComoUsar,
        tooltip: 'Cómo usar la app',
        child: Icon(Icons.help_outline),
      ),
    );
  }

  void _mostrarComoUsar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cómo usar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "1. Luego de un registro exitoso, podrás acceder a la sección 'Comenzar' para estacionarte."),
                SizedBox(height: 10),
                Text(
                    "2. Para una reserva exitosa, debes dirigirte a la sección de 'Buscar estacionamientos' y seleccionar el de tu preferencia y clickear 'Reservar', pudiendo terminar también tu reserva si te desocupas antes de lo presupuestado."),
                SizedBox(height: 10),
                Text(
                    "3. Puedes cancelar una reserva, siempre y cuando sea mínimo media hora antes de la hora de reserva."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarTerminosYCondiciones() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Términos y Condiciones"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "1. Al utilizar esta aplicación, usted se compromete a pagar todas las tarifas asociadas, incluyendo cargos a la tarifa por incumplimiento."),
                SizedBox(height: 10),
                Text(
                    "2. No nos hacemos responsables de daños a vehículos ni sus pertenencias."),
                SizedBox(height: 10),
                Text("3. Aplicación solo para mayores de edad."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Las contraseñas no coinciden.'),
        ),
      );
      return;
    }

    if (!aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes aceptar los términos y condiciones.'),
        ),
      );
      return;
    }

    bool userExists = await checkUserExistence(
      usuarioController.text,
      correoController.text,
    );

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre de usuario o el correo ya están en uso.'),
        ),
      );
      return;
    }

    int user_id = await registerUser(
      name: nombreApellidoController.text,
      username: usuarioController.text,
      email: correoController.text,
      password: (passwordController.text),
      role: 'user',
      is_active: true,
    );

    if (user_id != 0) {
      final walletCreated = await createWallet(userId: user_id);
      if (walletCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso! Bienvenido!'),
          backgroundColor: Colors.green,
        ),
      );
      };
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Hubo un problema al registrarse. Por favor, inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, introduce una contraseña.';
        } else if (value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }
}
