// ignore_for_file: unused_field

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String _userId;

  Future<void> signup(String email, String password) async {
    String authId = 'AIzaSyCiAX461bCWh0qTCDHLz9G9Kph91Vzncgo';
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$authId');
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    // ignore: avoid_print
    print(json.decode(response.body));
  }

  Future<void> login(String email, String password) async {
    String authId = 'AIzaSyCiAX461bCWh0qTCDHLz9G9Kph91Vzncgo';
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$authId');
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    // ignore: avoid_print
    print(json.decode(response.body));
  }
}
