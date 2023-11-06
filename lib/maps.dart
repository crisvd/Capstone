  import 'package:flutter/material.dart';
  import 'map_screen.dart'; // Import the new Dart file
  import 'tabs.dart';
  import 'package:provider/provider.dart';
  import 'dark_mode_manager.dart';
  import 'dart:convert';
  import 'package:crypto/crypto.dart';
  import 'package:collection/collection.dart';

  class MapsScreen extends StatefulWidget {
    @override
    _MapsScreenState createState() => _MapsScreenState();
  }

  class _MapsScreenState extends State<MapsScreen> {
    String decodeJwt(String token, String secret) {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      final header = json.decode(utf8.decode(base64Url.decode(parts[0])));
      final payload = json.decode(utf8.decode(base64Url.decode(parts[1])));

      final signature = base64Url.decode(parts[2]);

      final String algorithm = header['alg'];
      if (algorithm != 'HS512') {
        throw Exception('Invalid algorithm');
      }

      final hmac = Hmac(sha512, utf8.encode(secret));
      final digest = hmac.convert(utf8.encode('${parts[0]}.${parts[1]}'));

      if (const ListEquality().equals(digest.bytes, signature)) {
        return json.encode(payload);
      } else {
        throw Exception('Invalid signature');
      }
    }

    @override
    void initState() {
      super.initState();

      final jwt = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb25pX2NyaXMiLCJ1c2VyX2lkIjoyMywiZXhwIjoxNjk4NTA2ODY1LCJpYXQiOjE2OTg1MDUwNjV9.m_AvVutcHTFcuIQ3w0a9FDaNaywWsCI8uuYxzJVONf4n5TQ_t9fQCzAWDB8pYB91U5RA87zxFnAnBINdfEytMw"; // Replace with your JWT
      final secret = '9a906627c7d4dac428f7ca952626b15e4cae78aa8f784527637f46ed5aba1eaa'; // Replace with your secret key

      try {
        final decodedPayload = decodeJwt(jwt, secret);
        print('Decoded Payload: $decodedPayload');
      } catch (e) {
        print('Error: $e');
      }
    }

    @override
    Widget build(BuildContext context) {
      final darkModeManager = Provider.of<DarkModeManager>(context); // Use Provider.of

      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

      return MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Selecciona Tu Estacionamiento!!'),
          ),
          drawer: buildDrawer(context),
          body: MapScreen(), // Use the new MapScreen widget
        ),
      );
    }
  }
